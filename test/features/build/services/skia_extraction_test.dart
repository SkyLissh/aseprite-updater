import "dart:async";
import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:archive/archive_io.dart";

import "package:aseprite_updater/features/build/services/services.dart";

void main() {
  late Directory temporary;
  late Directory destination;
  late SkiaService service;

  File extracted(String path) => File.fromUri(destination.uri.resolve(path));
  List<ArchiveFile> files() => [
    ArchiveFile.string("include/header.h", "header"),
    ArchiveFile.string("lib/library.a", "library"),
  ];

  Future<void> writeZip(List<ArchiveFile> entries) async {
    final archive = Archive();
    for (final entry in entries) {
      archive.add(entry);
    }
    await extracted("skia.zip").writeAsBytes(ZipEncoder().encode(archive));
  }

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp("skia-extraction-");
    destination = await Directory.fromUri(temporary.uri.resolve("skia%20with%20spaces/")).create();
    service = SkiaService(
      destination,
      releaseTag: "test-skia",
      assetName: "Skia-Linux-Release-x64.zip",
    );
  });
  tearDown(() => temporary.delete(recursive: true));

  test("extracts into the configured directory and reports completed files", () async {
    await writeZip([ArchiveFile.directory("./"), ArchiveFile.directory("empty/"), ...files()]);
    final progress = <(int, int?)>[];

    await for (final update in service.extract()) {
      progress.add((update.completedFiles, update.totalFiles));
      if (update.completedFiles >= 1) {
        expect(await extracted("include/header.h").readAsString(), "header");
      }
      if (update.completedFiles == 2) {
        expect(await extracted("lib/library.a").readAsString(), "library");
      }
    }

    expect(progress, [(0, 2), (1, 2), (2, 2)]);
    expect(await Directory.fromUri(destination.uri.resolve("empty/")).exists(), isTrue);
  });

  for (final path in ["../escaped.txt", "/escaped.txt"]) {
    test("rejects an archive entry outside the destination: $path", () async {
      await writeZip([ArchiveFile.string(path, "escaped"), ...files()]);

      await expectLater(service.extract().toList(), throwsA(isA<ArchiveException>()));
      expect(await File.fromUri(temporary.uri.resolve("escaped.txt")).exists(), isFalse);
    });
  }

  test("does not overwrite the ZIP it is reading", () async {
    await writeZip([ArchiveFile.string("skia.zip", "replace"), ...files()]);
    final original = await extracted("skia.zip").readAsBytes();

    await expectLater(service.extract().toList(), throwsA(isA<ArchiveException>()));
    expect(await extracted("skia.zip").readAsBytes(), original);
  });

  for (final kind in ["empty", "invalid"]) {
    test("rejects an $kind archive", () async {
      if (kind == "empty") {
        await writeZip([]);
      } else {
        await extracted("skia.zip").writeAsString("not a ZIP");
      }

      await expectLater(service.extract().toList(), throwsA(isA<ArchiveException>()));
    });
  }

  test("propagates a missing archive as a filesystem error", () async {
    await expectLater(service.extract().toList(), throwsA(isA<FileSystemException>()));
  });

  test("a filesystem write error does not report the file as completed", () async {
    await writeZip(files());
    await Directory(extracted("include/header.h").path).create(recursive: true);
    final progress = <int>[];

    await expectLater(
      service.extract().forEach((update) => progress.add(update.completedFiles)),
      throwsA(isA<FileSystemException>()),
    );
    expect(progress, [0]);
  });

  test("cancelling extraction stops before the next file", () async {
    await writeZip(files());
    final iterator = StreamIterator(service.extract());
    expect(await iterator.moveNext(), isTrue);
    expect(await iterator.moveNext(), isTrue);

    await iterator.cancel();

    expect(await extracted("include/header.h").exists(), isTrue);
    expect(await extracted("lib/library.a").exists(), isFalse);
  });
}
