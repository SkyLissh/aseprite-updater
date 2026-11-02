import "dart:convert";
import "dart:io";

import "package:path/path.dart" as p;

class DeploymentService({
  required final Directory build,
  required final Directory checkout,
  required final Directory installation,
  required final File desktopEntry,
  required final File icon,
  required final Link commandLink,
}) {
  Future<void> deploy({required String tag}) async {
    if (!Platform.isLinux) {
      throw UnsupportedError("Aseprite deployment currently supports Linux only");
    }

    await _install();
    await _publishDesktopEntry();
    await _publishCommand();
    await _saveRelease(tag);
  }

  Future<void> _install() async {
    final buildDirectory = build.absolute.path;
    final installationDirectory = installation.absolute.path;
    final installScript = File(p.join(buildDirectory, "cmake_install.cmake"));

    if (!await installScript.exists()) {
      throw StateError("CMake install script not found: ${installScript.path}");
    }

    final arguments = ["--install", buildDirectory, "--prefix", installationDirectory];
    final result = await Process.run("cmake", arguments);

    if (result.exitCode != 0) {
      throw ProcessException(
        "cmake",
        arguments,
        "Aseprite installation failed.\n${result.stdout}\n${result.stderr}",
        result.exitCode,
      );
    }

    final executable = File(p.join(installationDirectory, "bin", "aseprite"));
    if (!await executable.exists()) {
      throw StateError("Installed Aseprite executable not found: ${executable.path}");
    }

    final data = Directory(p.join(installationDirectory, "share", "aseprite", "data"));
    if (!await data.exists()) {
      throw StateError("Installed Aseprite data directory not found: ${data.path}");
    }
  }

  String _escapeDesktopValue(String value) => value
      .replaceAll(r"\", r"\\")
      .replaceAll("\n", r"\n")
      .replaceAll("\t", r"\t")
      .replaceAll("\r", r"\r");

  Future<void> _publishDesktopEntry() async {
    final destination = desktopEntry.absolute;
    final type = await FileSystemEntity.type(destination.path, followLinks: false);

    if (type != FileSystemEntityType.file && type != FileSystemEntityType.notFound) {
      throw StateError("Desktop entry destination is not a regular file: ${destination.path}");
    }

    final iconDestination = icon.absolute;
    final iconType = await FileSystemEntity.type(iconDestination.path, followLinks: false);
    if (iconType != FileSystemEntityType.file && iconType != FileSystemEntityType.notFound) {
      throw StateError("Icon destination is not a regular file: ${iconDestination.path}");
    }

    final executable = p.join(installation.absolute.path, "bin", "aseprite");
    if (executable.contains("=")) {
      throw StateError("Desktop entry executable paths cannot contain '=': $executable");
    }

    final quotedExecutable = executable
        .replaceAllMapped(RegExp(r'["`$\\]'), (match) => "\\${match[0]}")
        .replaceAll("%", "%%");

    final installedIcon = File(
      p.join(installation.absolute.path, "share", "aseprite", "data", "icons", "ase256.png"),
    );

    final replacements = {
      "Exec": 'Exec="${_escapeDesktopValue(quotedExecutable)}" %U',
      "TryExec": "TryExec=${_escapeDesktopValue(executable)}",
      "Icon": "Icon=aseprite",
    };

    final template = File(
      p.join(checkout.absolute.path, "src", "desktop", "linux", "aseprite.desktop"),
    );

    final lines = const LineSplitter().convert(await template.readAsString());
    var inDesktopEntry = false;

    final entry = lines
        .map((line) {
          final trimmed = line.trim();
          if (trimmed.startsWith("[") && trimmed.endsWith("]")) {
            inDesktopEntry = trimmed == "[Desktop Entry]";
          }

          if (!inDesktopEntry) return line;

          final separator = line.indexOf("=");
          if (separator == -1) return line;

          final key = line.substring(0, separator).trim();
          return replacements[key] ?? line;
        })
        .join("\n");

    await iconDestination.parent.create(recursive: true);
    await installedIcon.copy(iconDestination.path);

    await destination.parent.create(recursive: true);
    await destination.writeAsString("$entry\n");
  }

  Future<void> _publishCommand() async {
    final executable = File(p.join(installation.absolute.path, "bin", "aseprite"));
    if (!await executable.exists()) {
      throw StateError("Installed Aseprite executable not found: ${executable.path}");
    }

    final destination = commandLink.absolute;
    final type = await FileSystemEntity.type(destination.path, followLinks: false);

    if (type == FileSystemEntityType.link && await File(destination.path).exists()) {
      final target = await destination.resolveSymbolicLinks();
      final expected = await executable.resolveSymbolicLinks();
      if (p.equals(target, expected)) return;
    }

    if (type != FileSystemEntityType.notFound) {
      throw StateError("Command destination already exists: ${destination.path}");
    }

    await destination.parent.create(recursive: true);
    await destination.create(executable.path);
  }

  Future<void> _saveRelease(String tag) async {
    final release = File(p.join(installation.path, "release"));

    await release.writeAsString(tag, flush: true);
  }
}
