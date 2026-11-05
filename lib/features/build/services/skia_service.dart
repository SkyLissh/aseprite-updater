import "dart:io";

import "package:dio/dio.dart";
import "package:archive/archive_io.dart";
import "package:path/path.dart" as p;

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/release/models/models.dart";

class SkiaService(final Directory directory, {Dio? client}) {
  final assetName = _resolveAssetName();

  final _api =
      client ??
      Dio(
        BaseOptions(
          baseUrl: "https://api.github.com/repos/aseprite/skia",
          headers: {"Accept": "application/vnd.github+json"},
        ),
      );

  static String _resolveAssetName() {
    if (Platform.isLinux) {
      return "Skia-Linux-Release-x64.zip";
    } else if (Platform.isMacOS) {
      return "Skia-macOS-Release-x64.zip";
    } else if (Platform.isWindows) {
      return "Skia-Windows-Release-x64.zip";
    } else {
      throw UnsupportedError("Unsupported platform: ${Platform.operatingSystem}");
    }
  }

  Future<String?> installedTag() async {
    final release = File(p.join(directory.path, "release"));

    if (!await release.exists()) return null;

    return (await release.readAsString()).trim();
  }

  Stream<DownloadProgress> download({required String releaseTag}) {
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

  Stream<ExtractingProgress> extract({required String releaseTag}) async* {
    final zip = File.fromUri(directory.uri.resolve("skia.zip"));
    final inputStream = InputFileStream(zip.path);

    try {
      final archive = ZipDecoder().decodeStream(inputStream);
      if (archive.isEmpty) {
        throw ArchiveException("Skia archive is empty or invalid");
      }

      await _cleanup();

      final root = p.normalize(directory.absolute.path);
      final symlinks = <ArchiveFile>[];

      final totalFiles = archive.where((file) => file.isFile && !file.isSymbolicLink).length;
      var completedFiles = 0;

      yield ExtractingProgress(completedFiles: completedFiles, totalFiles: totalFiles);

      for (final file in archive) {
        final outputPath = _extractionPath(root, file.name);
        if (p.equals(outputPath, p.join(root, "skia.zip"))) {
          throw ArchiveException("Skia archive cannot overwrite itself");
        }

        if (file.isSymbolicLink) {
          symlinks.add(file);
          continue;
        }

        if (file.isFile) {
          final output = OutputFileStream(outputPath);

          try {
            // TODO: Move extraction to a worker isolate if UI stalls are reported.
            file.writeContent(output);
          } finally {
            await output.close();
          }

          yield ExtractingProgress(totalFiles: totalFiles, completedFiles: ++completedFiles);
        } else {
          await Directory(outputPath).create(recursive: true);
        }
      }

      for (final entry in symlinks) {
        final linkPath = _extractionPath(root, entry.name);
        _extractionPath(root, entry.symbolicLink!, parent: p.dirname(linkPath));

        await Link(linkPath).create(entry.symbolicLink!, recursive: true);
      }
    } finally {
      await inputStream.close();
    }

    final release = File(p.join(directory.path, "release"));
    await release.writeAsString(releaseTag, flush: true);
  }

  Future<void> _cleanup() async {
    final release = File(p.join(directory.path, "release"));
    if (await release.exists()) {
      await release.delete();
    }

    final zipPath = p.join(directory.path, "skia.zip");

    await for (final entry in directory.list(followLinks: false)) {
      if (p.equals(entry.path, zipPath)) continue;

      await entry.delete(recursive: true);
    }
  }

  String _extractionPath(String root, String name, {String? parent}) {
    final outputPath = p.normalize(p.join(parent ?? root, name));
    if (p.isAbsolute(name) || (outputPath != root && !p.isWithin(root, outputPath))) {
      throw ArchiveException("Skia archive path escapes the extraction directory: $name");
    }

    return outputPath;
  }
}
