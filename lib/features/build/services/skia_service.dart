import "dart:async";
import "dart:io";

import "package:dio/dio.dart";

import "package:aseprite_updater/features/build/models/models.dart";

class SkiaService(final Directory directory, {Dio? client}) {
  final Dio _api =
      client ??
      Dio(
        BaseOptions(
          baseUrl: "https://api.github.com/repos/aseprite/skia",
          headers: {"Accept": "application/vnd.github+json"},
        ),
      );

  Stream<BuildEvent> donwload() async* {
    await directory.create(recursive: true);

    final archive = File.fromUri(directory.uri.resolve("skia.zip"));

    yield const PhaseChanged(.downloadingSkia);
  
    final events = StreamController<BuildEvent>();
  
    Future<void> finish() async {
      try {
        await archive.delete();

        await _api.download("/releases/latest", archive.path, onReceiveProgress: (received, total) {
          final value = total > 0 ? received / total : null;

          events.add(ProgressChanged(operation: .downloadingSkia, value: value));
        });
      }
    }
  }
}
