import "dart:io";

import "package:aseprite_updater/features/build/models/models.dart";

class SkiaService(final Directory directory) {
  Stream<DownloadProgress> download({required String url}) =>
      throw UnimplementedError("Skia downloading is not implemented yet.");
}
