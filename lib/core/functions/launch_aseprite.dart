import "dart:io";

import "package:path/path.dart" as p;

Future<void> launchAseprite(Directory installation) async {
  if (Platform.isLinux) {
    final executable = p.join(installation.absolute.path, "bin", "aseprite");

    await Process.start(executable, const [], mode: .detached);
  } else {
    throw UnsupportedError("Platform not supported");
  }
}
