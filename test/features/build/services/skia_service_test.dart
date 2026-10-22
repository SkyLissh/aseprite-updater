import "dart:async";
import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:flutter_test/flutter_test.dart";

import "package:dio/dio.dart";

import "package:aseprite_updater/features/build/services/services.dart";

void main() {
  const releaseTag = "m124-08a5439a6b";
  const assetName = "Skia-Linux-Release-x64.zip";
  const assetUrl = "https://example.invalid/skia.zip";
  final bytes = Uint8List.fromList([80, 75, 3, 4, 1, 2]);
  late Directory temporary;
  late Directory destination;
  late Dio client;
  late _ResponseAdapter adapter;
  late SkiaService service;

  ResponseBody metadata({bool includeAsset = true}) => ResponseBody.fromString(
    jsonEncode({
      "tag_name": releaseTag,
      "name": "Skia",
      "body": "Precompiled Skia packages",
      "published_at": "2025-01-02T03:04:05Z",
      "draft": false,
      "prerelease": false,
      "assets": [
        {"name": "other.zip", "browser_download_url": "https://example.invalid/other.zip"},
        if (includeAsset) {"name": assetName, "browser_download_url": assetUrl},
      ],
    }),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp("skia-download-");
    destination = Directory.fromUri(temporary.uri.resolve("skia/"));
    adapter = _ResponseAdapter();
    client = Dio(BaseOptions(baseUrl: "https://api.github.com/repos/aseprite/skia"))
      ..httpClientAdapter = adapter;
    service = SkiaService(
      destination,
      releaseTag: releaseTag,
      assetName: assetName,
      client: client,
    );
  });

  tearDown(() async {
    client.close(force: true);
    await temporary.delete(recursive: true);
  });

  test("downloads the configured asset rather than saving release metadata", () async {
    adapter.respond = (request) => request.path == assetUrl
        ? ResponseBody.fromBytes(
            bytes,
            200,
            headers: {
              Headers.contentLengthHeader: ["${bytes.length}"],
            },
          )
        : metadata();

    final progress = await service.download().toList();

    expect(adapter.requests.map((request) => request.path), [
      "/releases/tags/$releaseTag",
      assetUrl,
    ]);
    expect(adapter.requests.first.cancelToken, isNotNull);
    expect(adapter.requests.last.cancelToken, same(adapter.requests.first.cancelToken));
    expect(await File.fromUri(destination.uri.resolve("skia.zip")).readAsBytes(), bytes);
    expect(progress.last.receivedBytes, bytes.length);
    expect(progress.last.totalBytes, bytes.length);
  });

  test("reports received bytes when the server omits the total", () async {
    adapter.respond = (request) =>
        request.path == assetUrl ? ResponseBody.fromBytes(bytes, 200) : metadata();

    final progress = await service.download().toList();

    expect(progress, isNotEmpty);
    expect(progress.last.receivedBytes, bytes.length);
    expect(progress.last.totalBytes, isNull);
  });

  test("fails clearly when the configured asset is absent", () async {
    adapter.respond = (_) => metadata(includeAsset: false);

    await expectLater(
      service.download().toList(),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          "message",
          allOf(contains(assetName), contains(releaseTag)),
        ),
      ),
    );
    expect(adapter.requests, hasLength(1));
    expect(await File.fromUri(destination.uri.resolve("skia.zip")).exists(), isFalse);
  });

  for (final failingRequest in ["metadata", "asset"]) {
    test("propagates $failingRequest HTTP errors through the stream", () async {
      adapter.respond = (request) {
        if (failingRequest == "metadata" || request.path == assetUrl) {
          return ResponseBody.fromString("not found", 404);
        }

        return metadata();
      };

      await expectLater(
        service.download().toList(),
        throwsA(isA<DioException>().having((error) => error.response?.statusCode, "status", 404)),
      );
    });
  }

  test("propagates directory creation failures without requesting metadata", () async {
    await File.fromUri(temporary.uri.resolve("skia")).create();

    await expectLater(service.download().toList(), throwsA(isA<FileSystemException>()));
    expect(adapter.requests, isEmpty);
  });

  test("cancels a pending metadata request when its listener cancels", () async {
    final requested = Completer<void>();
    final response = Completer<ResponseBody>();
    adapter.respond = (_) {
      requested.complete();
      return response.future;
    };
    final subscription = service.download().listen(
      (_) {},
      onError: (Object error) => fail("$error"),
    );
    await requested.future;

    await subscription.cancel();

    expect(adapter.requests.single.cancelToken!.isCancelled, isTrue);
    response.complete(metadata());
    await Future<void>.delayed(Duration.zero);
    expect(adapter.requests, hasLength(1));
  });

  test("cancels an active asset download when its listener cancels", () async {
    final requested = Completer<void>();
    final bodyCancelled = Completer<void>();
    final received = Completer<void>();
    final body = StreamController<Uint8List>(onCancel: bodyCancelled.complete);
    addTearDown(body.close);
    adapter.respond = (request) {
      if (request.path != assetUrl) return metadata();

      requested.complete();
      return ResponseBody(body.stream, 200);
    };
    final subscription = service.download().listen(
      (_) => received.complete(),
      onError: (Object error) => fail("$error"),
    );
    await requested.future;
    body.add(bytes);
    await received.future;

    await subscription.cancel();
    await bodyCancelled.future;

    expect(adapter.requests.last.cancelToken!.isCancelled, isTrue);
    await Future<void>.delayed(Duration.zero);
  });
}

class _ResponseAdapter implements HttpClientAdapter {
  late FutureOr<ResponseBody> Function(RequestOptions) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}
