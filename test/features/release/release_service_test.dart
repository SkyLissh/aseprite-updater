import "dart:convert";
import "dart:io";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as p;

import "package:aseprite_updater/features/release/services/services.dart";

import "support/release_fixture.dart";

void main() {
  late Directory installation;
  late Dio client;
  late _ResponseAdapter adapter;

  setUp(() async {
    installation = await Directory.systemTemp.createTemp("release-service-");
    adapter = _ResponseAdapter();
    client = Dio()..httpClientAdapter = adapter;
  });
  tearDown(() async {
    client.close(force: true);
    await installation.delete(recursive: true);
  });

  test("requests latest release and maps the JSON response", () async {
    adapter.respond = (_) => ResponseBody.fromString(
      jsonEncode(releaseJson()),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

    final release = await ReleaseService(
      installation: installation,
      client: client,
    ).getLatestRelease();

    expect(adapter.request!.method, "GET");
    expect(adapter.request!.path, "/releases/latest");
    expect(release, releaseFixture());
  });

  test("propagates unsuccessful HTTP status", () async {
    adapter.respond = (_) => ResponseBody.fromString("not found", 404);

    await expectLater(
      ReleaseService(installation: installation, client: client).getLatestRelease(),
      throwsA(isA<DioException>().having((error) => error.response?.statusCode, "status", 404)),
    );
  });

  for (final type in [DioExceptionType.connectionError, DioExceptionType.connectionTimeout]) {
    test("propagates $type without making a network request", () async {
      adapter.respond = (request) => throw DioException(requestOptions: request, type: type);

      await expectLater(
        ReleaseService(installation: installation, client: client).getLatestRelease(),
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

    await expectLater(
      ReleaseService(installation: installation, client: client).getLatestRelease(),
      throwsA(isA<TypeError>()),
    );
  });

  test("returns null when there is no installed release record", () async {
    final service = ReleaseService(installation: installation, client: client);

    expect(await service.installedRelease(), isNull);
    expect(adapter.request, isNull);
  });

  test("reads the installed tag from the release file", () async {
    await File(p.join(installation.path, "release")).writeAsString("v1.2.0");
    final service = ReleaseService(installation: installation, client: client);

    expect(await service.installedRelease(), "v1.2.0");
    expect(adapter.request, isNull);
  });

  for (final type in ReleaseType.values) {
    test("${type.name} selection handles a beta release", () async {
      adapter.respond = (_) => ResponseBody.fromString(
        jsonEncode({...releaseJson(), "tag_name": "v1.4-beta1", "prerelease": true}),
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
      final service = ReleaseService(installation: installation, client: client);

      if (type == ReleaseType.stable) {
        await expectLater(service.getLatestRelease(), throwsA(isA<Exception>()));
      } else {
        expect((await service.getLatestRelease(type: type)).tagName, "v1.4-beta1");
      }
    });
  }
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
