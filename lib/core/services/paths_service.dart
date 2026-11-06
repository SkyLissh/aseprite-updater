import "dart:io";

import "package:path/path.dart" as p;

class PathsService {
  final Directory root;

  new(this.root);

  Directory get src => Directory(p.join(root.path, "src"));
  Directory get checkout => Directory(p.join(src.path, "aseprite"));
  Directory get skia => Directory(p.join(root.path, "skia"));
  Directory get build => Directory(p.join(root.path, "build"));
  Directory get out => Directory(p.join(build.path, "out"));
  Directory get installation => Directory(p.join(root.path, "installed"));
  Directory get stagingInstallation => Directory(p.join(root.path, "installed.next"));

  File get desktopEntry => File(p.join(root.parent.path, "applications", "aseprite.desktop"));
  File get icon =>
      File(p.join(root.parent.path, "icons", "hicolor", "256x256", "apps", "aseprite.png"));

  Link get commandLink {
    final home = Platform.environment["HOME"];
    if (home == null || home.isEmpty || !p.isAbsolute(home)) {
      throw StateError("HOME environment variable must be set to an absolute path");
    }

    return Link(p.join(home, ".local", "bin", "aseprite"));
  }

  factory linux() {
    if (!Platform.isLinux) {
      throw UnsupportedError("Unsupported platform: ${Platform.operatingSystem}");
    }

    final xdgHome = Platform.environment["XDG_DATA_HOME"];

    if (xdgHome != null && xdgHome.startsWith("/")) {
      return PathsService(Directory(p.join(xdgHome, "aseprite-updater")));
    }

    final home = Platform.environment["HOME"];
    if (home == null || home.isEmpty) {
      throw StateError("HOME environment variable is not set");
    }

    return PathsService(Directory(p.join(home, ".local", "share", "aseprite-updater")));
  }

  Future<void> ensureDirectoriesExist() async {
    await Future.wait([
      src.create(recursive: true),
      skia.create(recursive: true),
      build.create(recursive: true),
      out.create(recursive: true),
    ]);
  }
}
