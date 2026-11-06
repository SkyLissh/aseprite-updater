import "dart:io";

import "package:path/path.dart" as p;

class InstallationService({
  required final Directory build,
  required final Directory installation,
  required final Directory stagingInstallation,
}) {
  Future<void> install({required String tag}) async {
    if (!Platform.isLinux) {
      throw UnsupportedError("Aseprite installation currently supports Linux only");
    }
    if (tag.trim().isEmpty) {
      throw ArgumentError.value(tag, "tag", "A release tag is required");
    }

    await _validateDestinations();
    if (await stagingInstallation.exists()) {
      await stagingInstallation.delete(recursive: true);
    }

    await _install();

    if (await installation.exists()) {
      await installation.delete(recursive: true);
    }
    await stagingInstallation.rename(installation.absolute.path);
    await File(p.join(installation.path, "release")).writeAsString(tag, flush: true);
  }

  Future<void> _validateDestinations() async {
    final active = p.normalize(installation.absolute.path);
    final staging = p.normalize(stagingInstallation.absolute.path);
    if (p.equals(active, staging) || !p.equals(p.dirname(active), p.dirname(staging))) {
      throw ArgumentError("Installation and staging must be distinct sibling directories");
    }

    for (final directory in [installation, stagingInstallation]) {
      final type = await FileSystemEntity.type(directory.path, followLinks: false);
      if (type != FileSystemEntityType.directory && type != FileSystemEntityType.notFound) {
        throw StateError("Installation destination is not a regular directory: ${directory.path}");
      }
    }
  }

  Future<void> _install() async {
    final buildDirectory = build.absolute.path;
    final installationDirectory = stagingInstallation.absolute.path;
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

    if (((await executable.stat()).mode & 0x40) == 0) {
      throw StateError("Installed Aseprite file is not executable: ${executable.path}");
    }

    final icon = File(
      p.join(installationDirectory, "share", "aseprite", "data", "icons", "ase256.png"),
    );
    if (!await icon.exists()) {
      throw StateError("Installed Aseprite icon not found: ${icon.path}");
    }

    final data = Directory(p.join(installationDirectory, "share", "aseprite", "data"));
    if (!await data.exists()) {
      throw StateError("Installed Aseprite data directory not found: ${data.path}");
    }
  }
}
