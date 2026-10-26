import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as p;

import "package:aseprite_updater/features/build/services/deployment_service.dart";

void main() {
  group("Linux deployment", () {
    late _DeploymentFixture fixture;

    setUp(() async {
      fixture = await _DeploymentFixture.create();
      await fixture.configure();
    });

    tearDown(() async => fixture.temporary.delete(recursive: true));

    test("installs executable and resources into the private prefix", () async {
      await fixture.service.deploy();

      expect(await fixture.executable.exists(), isTrue);
      expect((await fixture.executable.stat()).mode & 0x49, isNot(0));
      expect(await fixture.icon.readAsString(), "fixture icon");
      expect(await fixture.data.exists(), isTrue);
      expect(await Directory(p.join(fixture.build.path, "bin")).exists(), isFalse);
    });

    test("accepts relative inputs and publishes absolute paths", () async {
      final service = DeploymentService(
        build: Directory(p.relative(fixture.build.path)),
        checkout: Directory(p.relative(fixture.checkout.path)),
        installation: Directory(p.relative(fixture.installation.path)),
        desktopEntry: File(p.relative(fixture.desktopEntry.path)),
        icon: File(p.relative(fixture.iconDestination.path)),
        commandLink: Link(p.relative(fixture.commandLink.path)),
      );

      await service.deploy();

      expect(p.isAbsolute(await fixture.commandLink.target()), isTrue);
      expect(await fixture.commandLink.resolveSymbolicLinks(), fixture.executable.path);
      final lines = await fixture.desktopEntry.readAsLines();
      final executable = lines.singleWhere((line) => line.startsWith("TryExec=")).substring(8);
      expect(p.isAbsolute(executable), isTrue);
      expect(await File(executable).resolveSymbolicLinks(), fixture.executable.path);
    });

    test("waits for the CMake installation to finish", () async {
      final started = File(p.join(fixture.temporary.path, "install started"));
      final release = File(p.join(fixture.temporary.path, "release install"));
      await fixture.configure(
        beforeInstall:
            """
file(WRITE [==[${started.path}]==] "started")
while(NOT EXISTS [==[${release.path}]==])
  execute_process(COMMAND "\${CMAKE_COMMAND}" -E sleep 0.05)
endwhile()
""",
      );
      var completed = false;
      final deployment = fixture.service.deploy().whenComplete(() => completed = true);
      final result = expectLater(deployment, completes);

      try {
        final watch = Stopwatch()..start();
        while (!await started.exists() &&
            !completed &&
            watch.elapsed < const Duration(seconds: 10)) {
          await Future<void>.delayed(const Duration(milliseconds: 20));
        }

        expect(await started.exists(), isTrue, reason: "CMake must reach the installation gate");
        expect(completed, isFalse);
        await _expectNoIntegration(fixture);
      } finally {
        await release.writeAsString("continue");
        await result;
      }
    });

    test("rejects a missing install script before publishing integration", () async {
      await File(p.join(fixture.build.path, "cmake_install.cmake")).delete();

      await expectLater(fixture.service.deploy(), throwsA(isA<StateError>()));

      expect(await fixture.installation.exists(), isFalse);
      await _expectNoIntegration(fixture);
    });

    test("preserves CMake diagnostics, arguments, and failure exit code", () async {
      await fixture.configure(
        beforeInstall: 'message(STATUS "fixture stdout")\nmessage(FATAL_ERROR "fixture stderr")',
      );

      await expectLater(
        fixture.service.deploy(),
        throwsA(
          isA<ProcessException>()
              .having((error) => error.executable, "executable", "cmake")
              .having((error) => error.arguments, "arguments", [
                "--install",
                fixture.build.absolute.path,
                "--prefix",
                fixture.installation.absolute.path,
              ])
              .having((error) => error.errorCode, "exit code", isPositive)
              .having((error) => error.message, "stdout", contains("fixture stdout"))
              .having((error) => error.message, "stderr", contains("fixture stderr")),
        ),
      );

      await _expectNoIntegration(fixture);
    });

    test("leaves partial installation files on CMake failure", () async {
      final partial = File(p.join(fixture.installation.path, "partial"));
      await fixture.configure(
        beforeInstall:
            """
file(MAKE_DIRECTORY [==[${fixture.installation.path}]==])
file(WRITE [==[${partial.path}]==] "partial installation")
message(FATAL_ERROR "fixture failure")
""",
      );

      await expectLater(fixture.service.deploy(), throwsA(isA<ProcessException>()));

      expect(await partial.readAsString(), "partial installation");
      await _expectNoIntegration(fixture);
    });

    for (final missing in ["executable", "resources"]) {
      test("rejects an installation missing $missing", () async {
        await fixture.configure(
          executable: missing != "executable",
          resources: missing != "resources",
        );

        await expectLater(fixture.service.deploy(), throwsA(isA<StateError>()));

        await _expectNoIntegration(fixture);
      });
    }

    test("publishes the upstream desktop metadata with installed paths", () async {
      await fixture.service.deploy();

      final entry = await fixture.desktopEntry.readAsString();
      expect(entry, isNot(contains("# Managed by aseprite-updater")));
      expect(entry, contains("[Desktop Entry]"));
      expect(entry, contains("Name=Aseprite"));
      expect(entry, contains("Name[es]=Aseprite de prueba"));
      expect(entry, contains("Categories=Graphics;2DGraphics;"));
      expect(entry, contains('Exec="${fixture.executable.path}" %U'));
      expect(entry, contains("TryExec=${fixture.executable.path}"));
      expect(entry, contains("Icon=aseprite\n"));
      expect(await fixture.icon.exists(), isTrue);
      expect(await fixture.iconDestination.readAsBytes(), await fixture.icon.readAsBytes());
      expect(entry, isNot(contains("Exec=aseprite")));
    });

    test("preserves comments, localized values, and other desktop groups", () async {
      await fixture.template.writeAsString("""
# Upstream comment
Comment[es]=Editor de sprites
[Desktop Action Preview]
Name=Preview
Exec=preview-command --flag
Icon=preview-icon
""", mode: FileMode.append);

      await fixture.service.deploy();

      final entry = await fixture.desktopEntry.readAsString();
      expect(entry, contains("# Upstream comment"));
      expect(entry, contains("Comment[es]=Editor de sprites"));
      expect(
        entry,
        contains("[Desktop Action Preview]\nName=Preview\nExec=preview-command --flag"),
      );
      expect(entry, contains("Icon=preview-icon"));
    });

    test("rejects an equals sign in the executable path before publishing integration", () async {
      final service = DeploymentService(
        build: fixture.build,
        checkout: fixture.checkout,
        installation: Directory(p.join(fixture.temporary.path, "installed=aseprite")),
        desktopEntry: fixture.desktopEntry,
        icon: fixture.iconDestination,
        commandLink: fixture.commandLink,
      );

      await expectLater(service.deploy(), throwsA(isA<StateError>()));

      await _expectNoIntegration(fixture);
    });

    test("escapes literal percent signs in the Exec executable path", () async {
      final service = DeploymentService(
        build: fixture.build,
        checkout: fixture.checkout,
        installation: Directory(p.join(fixture.temporary.path, "installed 100%")),
        desktopEntry: fixture.desktopEntry,
        icon: fixture.iconDestination,
        commandLink: fixture.commandLink,
      );

      await service.deploy();

      final entry = await fixture.desktopEntry.readAsString();
      expect(entry, contains('Exec="${fixture.temporary.path}/installed 100%%/bin/aseprite" %U'));
      expect(entry, contains("TryExec=${fixture.temporary.path}/installed 100%/bin/aseprite"));
    });

    test("escapes quotes, backticks, and dollar signs in Exec", () async {
      const name = r'installed "`$';
      final installation = Directory(p.join(fixture.temporary.path, name));
      final service = DeploymentService(
        build: fixture.build,
        checkout: fixture.checkout,
        installation: installation,
        desktopEntry: fixture.desktopEntry,
        icon: fixture.iconDestination,
        commandLink: fixture.commandLink,
      );

      await service.deploy();

      final entry = await fixture.desktopEntry.readAsString();
      const escaped = r'installed \\"\\`\\$';
      expect(entry, contains('Exec="${fixture.temporary.path}/$escaped/bin/aseprite" %U'));
      expect(entry, contains('TryExec=${installation.path.replaceAll(r"\", r"\\")}/bin/aseprite'));
    });

    test("escapes backslashes in Exec when supported by CMake", () async {
      final service = DeploymentService(
        build: fixture.build,
        checkout: fixture.checkout,
        installation: Directory(p.join(fixture.temporary.path, r"installed \ path")),
        desktopEntry: fixture.desktopEntry,
        icon: fixture.iconDestination,
        commandLink: fixture.commandLink,
      );

      try {
        await service.deploy();
      } on ProcessException catch (error) {
        if (error.executable != "cmake" || !error.message.contains("file INSTALL destination")) {
          rethrow;
        }

        await _expectNoIntegration(fixture);
        markTestSkipped("CMake cannot install into this prefix containing a literal backslash");
        return;
      }

      final entry = await fixture.desktopEntry.readAsString();
      const escaped = r"installed \\\\ path";
      expect(entry, contains('Exec="${fixture.temporary.path}/$escaped/bin/aseprite" %U'));
    });

    test("generated launcher passes desktop-file-validate when available", () async {
      await fixture.service.deploy();

      final ProcessResult result;
      try {
        result = await Process.run("desktop-file-validate", [fixture.desktopEntry.path]);
      } on ProcessException catch (error) {
        if (error.errorCode != 2) rethrow;
        markTestSkipped("desktop-file-validate is not installed");
        return;
      }

      expect(result.exitCode, 0, reason: "${result.stdout}\n${result.stderr}");
    });

    test("overwrites an existing regular desktop entry", () async {
      await fixture.desktopEntry.parent.create(recursive: true);
      await fixture.desktopEntry.writeAsString("old entry\n");

      await fixture.service.deploy();

      expect(await fixture.desktopEntry.readAsString(), contains("Name=Aseprite"));
      expect(await fixture.desktopEntry.readAsString(), isNot(contains("old entry")));
    });

    test("overwrites an existing regular fallback icon", () async {
      await fixture.iconDestination.parent.create(recursive: true);
      await fixture.iconDestination.writeAsString("old icon");

      await fixture.service.deploy();

      expect(await fixture.iconDestination.readAsBytes(), await fixture.icon.readAsBytes());
    });

    test("a missing installed icon prevents launcher and command publication", () async {
      await File(p.join(fixture.checkout.path, "data", "icons", "ase256.png")).delete();

      await expectLater(fixture.service.deploy(), throwsA(isA<FileSystemException>()));

      await _expectNoIntegration(fixture);
    });

    test("a missing upstream template prevents command publication", () async {
      await fixture.template.delete();

      await expectLater(fixture.service.deploy(), throwsA(isA<FileSystemException>()));

      expect(await fixture.executable.exists(), isTrue);
      await _expectNoIntegration(fixture);
    });

    for (final kind in ["directory", "symlink"]) {
      test("preserves a foreign desktop $kind and does not publish a command", () async {
        await _createForeignPath(fixture.desktopEntry.path, kind, fixture);

        await expectLater(fixture.service.deploy(), throwsA(isA<StateError>()));

        await _expectForeignPath(fixture.desktopEntry.path, kind, fixture);
        expect(
          await FileSystemEntity.type(fixture.commandLink.path, followLinks: false),
          FileSystemEntityType.notFound,
        );
        expect(await fixture.iconDestination.exists(), isFalse);
      });

      test("preserves an icon destination $kind and does not publish a launcher", () async {
        await _createForeignPath(fixture.iconDestination.path, kind, fixture);

        await expectLater(fixture.service.deploy(), throwsA(isA<StateError>()));

        await _expectForeignPath(fixture.iconDestination.path, kind, fixture);
        expect(await fixture.desktopEntry.exists(), isFalse);
        expect(
          await FileSystemEntity.type(fixture.commandLink.path, followLinks: false),
          FileSystemEntityType.notFound,
        );
      });
    }

    for (final kind in ["file", "directory", "symlink"]) {
      test("preserves a foreign command $kind", () async {
        await _createForeignPath(fixture.commandLink.path, kind, fixture);

        await expectLater(fixture.service.deploy(), throwsA(isA<StateError>()));

        await _expectForeignPath(fixture.commandLink.path, kind, fixture);
      });
    }

    test("creates an absolute terminal symlink that invokes the executable", () async {
      await fixture.service.deploy();

      expect(await fixture.commandLink.target(), fixture.executable.absolute.path);
      final result = await Process.run(fixture.commandLink.path, const []);
      expect(result.exitCode, 0);
      expect(result.stdout, "fixture aseprite\n");
    });

    test("repeat deployment preserves the command link and desktop content", () async {
      await fixture.service.deploy();
      final entry = await fixture.desktopEntry.readAsString();

      await fixture.service.deploy();

      expect(await fixture.desktopEntry.readAsString(), entry);
      expect(await fixture.commandLink.target(), fixture.executable.absolute.path);
      expect(await fixture.iconDestination.readAsBytes(), await fixture.icon.readAsBytes());
    });

    test("preserves a dangling foreign terminal link", () async {
      await fixture.commandLink.parent.create(recursive: true);
      final target = p.join(fixture.temporary.path, "missing executable");
      await fixture.commandLink.create(target);

      await expectLater(fixture.service.deploy(), throwsA(isA<StateError>()));

      expect(await fixture.commandLink.target(), target);
      expect(await File(target).exists(), isFalse);
    });

    test("preserves an equivalent terminal link through another symlink", () async {
      final alias = Link(p.join(fixture.temporary.path, "aseprite alias"));
      await alias.create(fixture.executable.path);
      await fixture.commandLink.parent.create(recursive: true);
      await fixture.commandLink.create(alias.path);

      await fixture.service.deploy();

      expect(await fixture.commandLink.target(), alias.path);
      expect(await fixture.commandLink.resolveSymbolicLinks(), fixture.executable.path);
    });

    test("preserves an equivalent relative terminal link", () async {
      await fixture.commandLink.parent.create(recursive: true);
      final target = p.relative(fixture.executable.path, from: fixture.commandLink.parent.path);
      await fixture.commandLink.create(target);

      await fixture.service.deploy();

      expect(await fixture.commandLink.target(), target);
      expect(await fixture.commandLink.resolveSymbolicLinks(), fixture.executable.path);
    });
  }, skip: !Platform.isLinux);

  test("rejects unsupported platforms before filesystem changes", () async {
    final fixture = await _DeploymentFixture.create();
    addTearDown(() => fixture.temporary.delete(recursive: true));

    await expectLater(fixture.service.deploy(), throwsUnsupportedError);

    expect(await fixture.installation.exists(), isFalse);
    await _expectNoIntegration(fixture);
  }, skip: Platform.isLinux);
}

Future<void> _expectNoIntegration(_DeploymentFixture fixture) async {
  for (final path in [
    fixture.desktopEntry.path,
    fixture.iconDestination.path,
    fixture.commandLink.path,
  ]) {
    expect(await FileSystemEntity.type(path, followLinks: false), FileSystemEntityType.notFound);
  }
}

Future<void> _createForeignPath(String path, String kind, _DeploymentFixture fixture) async {
  await Directory(p.dirname(path)).create(recursive: true);
  switch (kind) {
    case "file":
      await File(path).writeAsString("foreign content");
    case "directory":
      await Directory(path).create();
      await File(p.join(path, "keep")).writeAsString("foreign content");
    case "symlink":
      await Link(path).create(fixture.foreign.path);
  }
}

Future<void> _expectForeignPath(String path, String kind, _DeploymentFixture fixture) async {
  switch (kind) {
    case "file":
      expect(await File(path).readAsString(), "foreign content");
    case "directory":
      expect(await File(p.join(path, "keep")).readAsString(), "foreign content");
    case "symlink":
      expect(await Link(path).target(), fixture.foreign.path);
      expect(await fixture.foreign.readAsString(), "foreign content");
  }
}

class _DeploymentFixture(final Directory temporary) {
  Directory get checkout => Directory(p.join(temporary.path, "source checkout"));
  Directory get build => Directory(p.join(temporary.path, "build output"));
  Directory get installation => Directory(p.join(temporary.path, "private installation"));
  File get desktopEntry => File(p.join(temporary.path, "applications", "aseprite.desktop"));
  File get iconDestination =>
      File(p.join(temporary.path, "icons", "hicolor", "256x256", "apps", "aseprite.png"));
  Link get commandLink => Link(p.join(temporary.path, "local bin", "aseprite"));
  File get executable => File(p.join(installation.path, "bin", "aseprite"));
  Directory get data => Directory(p.join(installation.path, "share", "aseprite", "data"));
  File get icon => File(p.join(data.path, "icons", "ase256.png"));
  File get template => File(p.join(checkout.path, "src", "desktop", "linux", "aseprite.desktop"));
  File get foreign => File(p.join(temporary.path, "foreign executable"));

  DeploymentService get service => DeploymentService(
    build: build,
    checkout: checkout,
    installation: installation,
    desktopEntry: desktopEntry,
    icon: iconDestination,
    commandLink: commandLink,
  );

  static Future<_DeploymentFixture> create() async {
    final temporary = await Directory.systemTemp.createTemp("updater deploy ");
    final fixture = _DeploymentFixture(temporary);
    try {
      await fixture.template.parent.create(recursive: true);
      await fixture.template.writeAsString("""
[Desktop Entry]
Type=Application
Name=Aseprite
Name[es]=Aseprite de prueba
Exec=aseprite %U
TryExec=aseprite
Icon=aseprite
Categories=Graphics;2DGraphics;
""");
      await File(p.join(fixture.checkout.path, "aseprite"))
          .writeAsString("#!/bin/sh\nprintf 'fixture aseprite\\n'\n");
      final icon = File(p.join(fixture.checkout.path, "data", "icons", "ase256.png"));
      await icon.parent.create(recursive: true);
      await icon.writeAsString("fixture icon");
      await fixture.foreign.writeAsString("foreign content");
      return fixture;
    } catch (_) {
      await temporary.delete(recursive: true);
      rethrow;
    }
  }

  Future<void> configure({
    bool executable = true,
    bool resources = true,
    String beforeInstall = "",
  }) async {
    await File(p.join(checkout.path, "CMakeLists.txt")).writeAsString("""
cmake_minimum_required(VERSION 3.20)
project(DeploymentFixture LANGUAGES NONE)
install(CODE [====[$beforeInstall]====])
${executable ? 'install(PROGRAMS aseprite DESTINATION bin)' : ''}
${resources ? 'install(DIRECTORY data DESTINATION share/aseprite)' : ''}
""");
    final arguments = ["-S", checkout.path, "-B", build.path];
    final result = await Process.run("cmake", arguments);
    if (result.exitCode != 0) {
      throw ProcessException(
        "cmake",
        arguments,
        "${result.stdout}\n${result.stderr}",
        result.exitCode,
      );
    }
  }
}
