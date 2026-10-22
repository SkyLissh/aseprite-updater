import "dart:io";

import "package:dio/dio.dart";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/release/models/models.dart";

class SkiaService(
  final Directory directory, {
  required final String releaseTag,
  required final String assetName,
  Dio? client,
}) {
  final _api =
      client ??
      Dio(
        BaseOptions(
          baseUrl: "https://api.github.com/repos/aseprite/skia",
          headers: {"Accept": "application/vnd.github+json"},
        ),
      );

  Stream<DownloadProgress> download() {
    return Stream<DownloadProgress>.multi((controller) async {
      final cancelToken = CancelToken();

      controller.onCancel = () => cancelToken.cancel("Subscription cancelled");

      try {
        await directory.create(recursive: true);

        final archive = File.fromUri(directory.uri.resolve("skia.zip"));

        final response = await _api.get<Map<String, dynamic>>(
          "/releases/tags/${Uri.encodeComponent(releaseTag)}",
          cancelToken: cancelToken,
        );
        final release = Release.fromJson(response.data!);
        final asset = release.assets.firstWhere(
          (asset) => asset.name == assetName,
          orElse: () =>
              throw StateError("Skia asset '$assetName' not found in release '$releaseTag'"),
        );

        await _api.download(
          asset.browserDownloadUrl,
          archive.path,
          cancelToken: cancelToken,
          options: Options(headers: {"Accept": "application/octet-stream"}),
          onReceiveProgress: (received, total) {
            if (!controller.isClosed && !cancelToken.isCancelled) {
              controller.add(
                DownloadProgress(receivedBytes: received, totalBytes: total > 0 ? total : null),
              );
            }
          },
        );
      } catch (error, stackTrace) {
        if (!cancelToken.isCancelled && !controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      } finally {
        if (!controller.isClosed) controller.close();
      }
    });
  }
}
