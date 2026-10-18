import "dart:async";
import "dart:convert";
import "dart:io";

class SourceService {
  final Directory checkout;

  new(this.checkout);

  /// Clones the selected tag and its submodules into a new [checkout].
  ///
  /// Emits stdout and stderr lines, including Git progress updates. Completion
  /// means cloning succeeded; startup and nonzero-exit failures are stream errors.
  /// Existing destinations are rejected, and failed clones are left in place.
  /// Cancelling the subscription does not terminate Git.
  Stream<String> clone({required String tag}) async* {
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
      "--progress",
      "--",
      "https://github.com/aseprite/aseprite.git",
      destination,
    ];

    final process = await Process.start(
      "git",
      arguments,
      environment: {"GIT_TERMINAL_PROMPT": "0"},
    );

    final output = StreamController<String>();

    Future<void> forward(Stream<List<int>> bytes) => bytes
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .forEach(output.add);

    Future<void> finish() async {
      try {
        var exitCode = 0;

        await Future.wait<void>([
          forward(process.stdout),
          forward(process.stderr),
          process.stdin.close(),
          process.exitCode.then((value) => exitCode = value),
        ]);

        if (exitCode != 0) {
          throw ProcessException(
            "git",
            arguments,
            "Aseprite clone failed. Check the Git output for details. "
                "An incomplete checkout may remain at $destination.",
            exitCode,
          );
        }
      } catch (error, stackTrace) {
        output.addError(error, stackTrace);
      } finally {
        await output.close();
      }
    }

    unawaited(finish());
    yield* output.stream;
  }
}
