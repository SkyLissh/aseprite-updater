import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as p;

import "package:aseprite_updater/core/services/paths_service.dart";
import "package:aseprite_updater/features/build/services/services.dart";
import "package:aseprite_updater/features/release/services/services.dart";

void main() {
  late Directory temporary;
  late PathsService paths;
  late Directory source;
  late InstallationService service;

  Future<void> configure({bool executable = true, bool resources = true, String after = ""}) async {
    await File(p.join(source.path, "CMakeLists.txt")).writeAsString("""
cmake_minimum_required(VERSION 3.20)
project(InstallationFixture LANGUAGES NONE)
${executable ? 'install(PROGRAMS aseprite DESTINATION bin)' : ''}
${resources ? 'install(DIRECTORY data DESTINATION share/aseprite)' : ''}
install(CODE [====[$after]====])
""");
    final result = await Process.run("cmake", ["-S", source.path, "-B", paths.build.path]);
    expect(result.exitCode, 0, reason: "${result.stdout}\n${result.stderr}");
  }

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp("installation-test-");
    paths = PathsService(temporary);
    source = await Directory(p.join(temporary.path, "source")).create();
    await File(p.join(source.path, "aseprite")).writeAsString("#!/bin/sh\nexit 0\n");
    final icon = File(p.join(source.path, "data", "icons", "ase256.png"));
    await icon.parent.create(recursive: true);
    await icon.writeAsString("icon");
    service = InstallationService(
      build: paths.build,
      installation: paths.installation,
      stagingInstallation: paths.stagingInstallation,
    );
    await configure();
  });
  tearDown(() async => temporary.delete(recursive: true));

  for (final failure in ["delete", "rename"]) {
    test("$failure failure propagates without rollback", () async {
      await service.install(tag: "v1");
      final failing = InstallationService(
        build: paths.build,
        installation: failure == "delete"
            ? _FailingDirectory(paths.installation, failDelete: true)
            : paths.installation,
        stagingInstallation: failure == "rename"
            ? _FailingDirectory(paths.stagingInstallation, failRename: true)
            : paths.stagingInstallation,
      );

      await expectLater(
        failing.install(tag: "v2"),
        throwsA(
          isA<FileSystemException>().having(
            (error) => error.message,
            "failed operation",
            contains(failure),
          ),
        ),
      );

      expect(await paths.stagingInstallation.exists(), isTrue);
      expect(await paths.installation.exists(), failure == "delete");
      if (failure == "delete") {
        expect(await ReleaseService(installation: paths.installation).installedRelease(), "v1");
      }
    });
  }

  test("working installation remains available while staging is pending", () async {
    await service.install(tag: "v1");
    final started = File(p.join(temporary.path, "started"));
    final proceed = File(p.join(temporary.path, "proceed"));
    await configure(
      after:
          """
file(WRITE [==[${started.path}]==] "started")
while(NOT EXISTS [==[${proceed.path}]==])
  execute_process(COMMAND "\${CMAKE_COMMAND}" -E sleep 0.05)
endwhile()
""",
    );
    var completed = false;
    final done = service.install(tag: "v2").whenComplete(() => completed = true);
    final result = expectLater(done, completes);

    try {
      final watch = Stopwatch()..start();
      while (!await started.exists() && !completed && watch.elapsed < const Duration(seconds: 10)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(await started.exists(), isTrue);
      expect(completed, isFalse);
      expect(await ReleaseService(installation: paths.installation).installedRelease(), "v1");
      expect(await File(p.join(paths.installation.path, "bin", "aseprite")).exists(), isTrue);
    } finally {
      await proceed.writeAsString("continue");
      await result;
    }
  });

  test("first installation records the installed tag without desktop integration", () async {
    await service.install(tag: "v1");

    expect(await File(p.join(paths.installation.path, "bin", "aseprite")).exists(), isTrue);
    expect(await ReleaseService(installation: paths.installation).installedRelease(), "v1");
    expect(await paths.stagingInstallation.exists(), isFalse);
  });

  test("replacement removes obsolete files and leftover staging", () async {
    await service.install(tag: "v1");
    await File(p.join(paths.installation.path, "obsolete")).writeAsString("old");
    await paths.stagingInstallation.create();
    await File(p.join(paths.stagingInstallation.path, "partial")).writeAsString("partial");

    await service.install(tag: "v2");

    expect(await File(p.join(paths.installation.path, "obsolete")).exists(), isFalse);
    expect(await File(p.join(paths.installation.path, "partial")).exists(), isFalse);
    expect(await ReleaseService(installation: paths.installation).installedRelease(), "v2");
  });

  for (final missing in ["executable", "resources", "icon", "permission"]) {
    test("invalid candidate ($missing) preserves the working installation", () async {
      await service.install(tag: "v1");
      if (missing == "icon") {
        await File(p.join(source.path, "data", "icons", "ase256.png")).delete();
      }
      await configure(
        executable: missing != "executable",
        resources: missing != "resources",
        after: missing == "permission"
            ? 'file(CHMOD [==[${p.join(paths.stagingInstallation.path, "bin", "aseprite")}]==] PERMISSIONS OWNER_READ OWNER_WRITE WORLD_EXECUTE)'
            : "",
      );

      await expectLater(
        service.install(tag: "v2"),
        throwsA(anyOf(isA<StateError>(), isA<FileSystemException>())),
      );

      expect(await ReleaseService(installation: paths.installation).installedRelease(), "v1");
      expect(await File(p.join(paths.installation.path, "bin", "aseprite")).exists(), isTrue);
    });
  }

  test("partial CMake failure keeps the active installation and diagnostics", () async {
    await service.install(tag: "v1");
    await configure(after: 'message(FATAL_ERROR "fixture failure")');

    await expectLater(
      service.install(tag: "v2"),
      throwsA(
        isA<ProcessException>()
            .having((error) => error.message, "diagnostic", contains("fixture failure"))
            .having(
              (error) => error.arguments.last,
              "prefix",
              paths.stagingInstallation.absolute.path,
            ),
      ),
    );

    expect(await ReleaseService(installation: paths.installation).installedRelease(), "v1");
    expect(await paths.stagingInstallation.exists(), isTrue);
  });

  test("release-write failure propagates after activation without rollback", () async {
    await service.install(tag: "v1");
    await configure(
      after: 'file(MAKE_DIRECTORY [==[${p.join(paths.stagingInstallation.path, "release")}]==])',
    );

    await expectLater(service.install(tag: "v2"), throwsA(isA<FileSystemException>()));

    expect(await paths.installation.exists(), isTrue);
    expect(await paths.stagingInstallation.exists(), isFalse);
    expect(await Directory(p.join(paths.installation.path, "release")).exists(), isTrue);
  });

  for (final which in ["active", "staging"]) {
    test("a foreign link at $which is rejected without touching its target", () async {
      final target = await Directory(p.join(temporary.path, "foreign")).create();
      final marker = await File(p.join(target.path, "keep")).writeAsString("keep");
      await Link(which == "active" ? paths.installation.path : paths.stagingInstallation.path)
          .create(target.path);

      await expectLater(service.install(tag: "v1"), throwsStateError);

      expect(await marker.readAsString(), "keep");
    });
  }
}

class _FailingDirectory(
  final Directory directory, {
  final bool failDelete = false,
  final bool failRename = false,
}) extends Fake implements Directory {
  @override
  String get path => directory.path;

  @override
  Directory get absolute => this;

  @override
  Future<bool> exists() => directory.exists();

  @override
  Future<FileSystemEntity> delete({bool recursive = false}) {
    if (failDelete) throw FileSystemException("injected delete failure", path);
    return directory.delete(recursive: recursive);
  }

  @override
  Future<Directory> rename(String newPath) {
    if (failRename) throw FileSystemException("injected rename failure", path);
    return directory.rename(newPath);
  }
}
