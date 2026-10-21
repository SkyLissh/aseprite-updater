import "dart:convert";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/release/services/services.dart";

import "support/release_fixture.dart";

void main() {
  late Dio client;
  late _ResponseAdapter adapter;

  setUp(() {
    adapter = _ResponseAdapter();
    client = Dio()..httpClientAdapter = adapter;
  });
  tearDown(() => client.close(force: true));

  test("requests latest release and maps the JSON response", () async {
    adapter.respond = (_) => ResponseBody.fromString(
      jsonEncode(releaseJson()),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

    final release = await RepoService(client: client).getLatestRelease();

    expect(adapter.request!.method, "GET");
    expect(adapter.request!.path, "/releases/latest");
    expect(release, releaseFixture());
  });

  test("propagates unsuccessful HTTP status", () async {
    adapter.respond = (_) => ResponseBody.fromString("not found", 404);

    await expectLater(
      RepoService(client: client).getLatestRelease(),
      throwsA(isA<DioException>().having((error) => error.response?.statusCode, "status", 404)),
    );
  });

  for (final type in [DioExceptionType.connectionError, DioExceptionType.connectionTimeout]) {
    test("propagates $type without making a network request", () async {
      adapter.respond = (request) => throw DioException(requestOptions: request, type: type);

      await expectLater(
        RepoService(client: client).getLatestRelease(),
        throwsA(isA<DioException>().having((error) => error.type, "type", type)),
      );
    });
  }

  test("rejects an invalid release response", () async {
    adapter.respond = (_) => ResponseBody.fromString(
      "{}",
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

    await expectLater(RepoService(client: client).getLatestRelease(), throwsA(isA<TypeError>()));
  });
}

class _ResponseAdapter implements HttpClientAdapter {
  late ResponseBody Function(RequestOptions) respond;
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;

    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}
