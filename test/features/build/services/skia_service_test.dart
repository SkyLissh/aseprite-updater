import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/services.dart";

void main() {
  test("the typed download stub fails without creating its directory", () async {
    final temporary = await Directory.systemTemp.createTemp("skia-stub-");
    addTearDown(() => temporary.delete(recursive: true));
    final destination = Directory("${temporary.path}/skia");
    final Stream<DownloadProgress> Function({required String url}) download = SkiaService(
      destination,
    ).download;

    expect(
      () => download(url: "https://example.invalid/skia.zip"),
      throwsA(isA<UnimplementedError>()),
    );
    expect(await destination.exists(), isFalse);
  });
}
