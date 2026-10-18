import "dart:io";

class PathsService {
  final Directory root;

  new(this.root);

  Directory get src => Directory("${root.path}/src");
  Directory get checkout => Directory("${src.path}/aseprite");
  Directory get skia => Directory("${root.path}/skia");
  Directory get build => Directory("${root.path}/build");
  Directory get out => Directory("${build.path}/out");

  factory linux() {
    if (!Platform.isLinux) {
      throw UnsupportedError("Unsupported platform: ${Platform.operatingSystem}");
    }

    final xdgHome = Platform.environment["XDG_DATA_HOME"];

    if (xdgHome != null && xdgHome.startsWith("/")) {
      return PathsService(Directory("$xdgHome/aseprite-updater"));
    }

    final home = Platform.environment["HOME"];
    if (home == null || home.isEmpty) {
      throw StateError("HOME environment variable is not set");
    }

    return PathsService(Directory("$home/.local/share/aseprite-updater"));
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
