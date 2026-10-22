import "dart:io";

class SourceService(final Directory checkout) {
  /// Clones the selected tag and its submodules into a new [checkout].
  ///
  /// Drains process output without reporting progress. Completion means cloning
  /// succeeded; startup and nonzero-exit failures throw.
  /// Existing destinations are rejected, and failed clones are left in place.
  Future<void> clone({required String tag}) async {
    if (tag.trim().isEmpty) {
      throw ArgumentError.value(tag, "tag", "A release tag is required");
    }

    final destination = checkout.absolute.path;
    final type = await FileSystemEntity.type(destination, followLinks: false);

    if (type != FileSystemEntityType.notFound) {
      throw StateError("Clone destination already exists: $destination");
    }

    await Directory(destination).parent.create(recursive: true);

    final arguments = [
      "clone",
      "--branch",
      tag,
      "--recurse-submodules",
      "--",
      "https://github.com/aseprite/aseprite.git",
      destination,
    ];

    final process = await Process.start(
      "git",
      arguments,
      environment: {"GIT_TERMINAL_PROMPT": "0"},
    );

    var exitCode = 0;

    await Future.wait<void>([
      process.stdout.drain<void>(),
      process.stderr.drain<void>(),
      process.stdin.close(),
      process.exitCode.then((value) => exitCode = value),
    ]);

    if (exitCode != 0) {
      throw ProcessException(
        "git",
        arguments,
        "Aseprite clone failed. An incomplete checkout may remain at $destination.",
        exitCode,
      );
    }
  }
}
