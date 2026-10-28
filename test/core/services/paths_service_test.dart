import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as p;

import "package:aseprite_updater/core/services/paths_service.dart";

void main() {
  late Directory temporary;
  setUp(() async => temporary = await Directory.systemTemp.createTemp("updater-paths-"));
  tearDown(() async => temporary.delete(recursive: true));

  test("installation resolves inside the updater root without creating it", () async {
    final paths = PathsService(temporary);

    expect(paths.installation.path, "${temporary.path}/installed");
    expect(await paths.installation.exists(), isFalse);
  });

  test("desktop entry resolves beside the updater root without creating it", () async {
    final paths = PathsService(Directory(p.join(temporary.path, "aseprite-updater")));

    expect(paths.desktopEntry.path, "${temporary.path}/applications/aseprite.desktop");
    expect(await paths.desktopEntry.exists(), isFalse);
    expect(await paths.desktopEntry.parent.exists(), isFalse);
  });

  test("icon resolves in the user hicolor theme without creating it", () async {
    final paths = PathsService(Directory(p.join(temporary.path, "aseprite-updater")));

    expect(paths.icon.path, "${temporary.path}/icons/hicolor/256x256/apps/aseprite.png");
    expect(await paths.icon.exists(), isFalse);
    expect(await paths.icon.parent.exists(), isFalse);
  });

  test("workspace paths join a root with a trailing separator", () {
    final paths = PathsService(Directory("${temporary.path}${p.separator}"));

    expect(paths.src.path, "${temporary.path}/src");
    expect(paths.checkout.path, "${temporary.path}/src/aseprite");
    expect(paths.skia.path, "${temporary.path}/skia");
    expect(paths.build.path, "${temporary.path}/build");
    expect(paths.out.path, "${temporary.path}/build/out");
    expect(paths.installation.path, "${temporary.path}/installed");
  });

  test("command link resolves under HOME without creating it", () async {
    final home = p.join(temporary.path, "home with spaces");

    final result = await _commandLinkWithHome(temporary, home);

    expect(result.exitCode, 0, reason: result.stderr.toString());
    expect(result.stdout, "$home/.local/bin/aseprite");
    expect(await Directory(home).exists(), isFalse);
  });

  for (final home in [null, "", "relative/home"]) {
    test("command link rejects HOME=${home ?? '<missing>'}", () async {
      final result = await _commandLinkWithHome(temporary, home);

      expect(result.exitCode, 1);
      expect(result.stderr, contains("HOME"));
      expect(result.stdout, isEmpty);
    });
  }

  test("existing workspace directories succeed repeatedly", () async {
    final paths = PathsService(temporary);
    await paths.ensureDirectoriesExist();
    await expectLater(paths.ensureDirectoriesExist(), completes);
    for (final directory in [paths.src, paths.skia, paths.build, paths.out]) {
      expect(await directory.exists(), isTrue);
    }
  });

  test("creates nested directories below a missing root", () async {
    final paths = PathsService(Directory(p.join(temporary.path, "nested", "workspace")));
    await paths.ensureDirectoriesExist();
    for (final directory in [paths.src, paths.skia, paths.build, paths.out]) {
      expect(await directory.exists(), isTrue);
    }
  });

  test("creation failures propagate", () async {
    final blocker = await File(p.join(temporary.path, "blocked")).create();
    final paths = PathsService(Directory(blocker.path));
    await expectLater(paths.ensureDirectoriesExist(), throwsA(isA<FileSystemException>()));
  });
}

Future<ProcessResult> _commandLinkWithHome(Directory temporary, String? home) async {
  final script = File(p.join(temporary.path, "command_link.dart"));
  await script.writeAsString('''
import "dart:io";

import "package:aseprite_updater/core/services/paths_service.dart";

void main() {
  try {
    stdout.write(PathsService(Directory.systemTemp).commandLink.path);
  } on StateError catch (error) {
    stderr.write(error.message);
    exitCode = 1;
  }
}
''');
  final environment = Map<String, String>.of(Platform.environment)..remove("HOME");
  if (home != null) {
    environment["HOME"] = home;
  }

  return Process.run(
    p.join(
      Directory.current.path,
      ".fvm",
      "flutter_sdk",
      "bin",
      "cache",
      "dart-sdk",
      "bin",
      "dart",
    ),
    [
      "--packages=${p.join(Directory.current.path, '.dart_tool', 'package_config.json')}",
      script.path,
    ],
    environment: environment,
    includeParentEnvironment: false,
  );
}
