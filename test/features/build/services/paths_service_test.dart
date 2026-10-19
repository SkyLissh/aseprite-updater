import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/build/services/services.dart";

void main() {
  late Directory temporary;
  setUp(() async => temporary = await Directory.systemTemp.createTemp("updater-paths-"));
  tearDown(() async => temporary.delete(recursive: true));

  test("existing workspace directories succeed repeatedly", () async {
    final paths = PathsService(temporary);
    await paths.ensureDirectoriesExist();
    await expectLater(paths.ensureDirectoriesExist(), completes);
    for (final directory in [paths.src, paths.skia, paths.build, paths.out]) {
      expect(await directory.exists(), isTrue);
    }
  });

  test("creates nested directories below a missing root", () async {
    final paths = PathsService(Directory("${temporary.path}/nested/workspace"));
    await paths.ensureDirectoriesExist();
    for (final directory in [paths.src, paths.skia, paths.build, paths.out]) {
      expect(await directory.exists(), isTrue);
    }
  });

  test("creation failures propagate", () async {
    final blocker = await File("${temporary.path}/blocked").create();
    final paths = PathsService(Directory(blocker.path));
    await expectLater(paths.ensureDirectoriesExist(), throwsA(isA<FileSystemException>()));
  });
}
