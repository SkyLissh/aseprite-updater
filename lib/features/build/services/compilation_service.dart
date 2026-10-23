import "dart:convert";
import "dart:io";

import "package:path/path.dart" as p;

import "package:aseprite_updater/features/build/models/models.dart";

class CompilationService({
  required final Directory checkout,
  required final Directory build,
  required final Directory skia,
  Future<ProcessResult> Function(String, List<String>)? runProcess,
  Future<Process> Function(String, List<String>, {Map<String, String>? environment})? startProcess,
}) {
  final Future<ProcessResult> Function(String, List<String>) _runProcess =
      runProcess ?? Process.run;

  final Future<Process> Function(String, List<String>, {Map<String, String>? environment})
  _startProcess = startProcess ?? Process.start;

  static final _ninjaProgress = RegExp(r"^__ASEPRITE_PROGRESS__\[(\d+)/(\d+)\] ");

  /// Compiles Aseprite and reports completed Ninja tasks.
  ///
  /// Cancellation requests termination, including after pending startup completes.
  /// Output draining and process cleanup continue in the background; cancelling
  /// the subscription does not wait for that cleanup.
  Stream<CompilationProgress> compile() {
    return Stream<CompilationProgress>.multi((controller) async {
      Process? process;
      controller.onCancel = () => process?.kill();

      try {
        if (!Platform.isLinux) {
          throw UnsupportedError("Aseprite compilation currently supports Linux only");
        }

        final buildDirectory = build.absolute.path;
        if (!await File(p.join(buildDirectory, "build.ninja")).exists()) {
          throw StateError("Run CMake configuration before compilation: $buildDirectory");
        }

        if (!controller.hasListener) return;

        final arguments = ["-C", buildDirectory, "aseprite"];
        final child = await _startProcess(
          "ninja",
          arguments,
          environment: {"NINJA_STATUS": "__ASEPRITE_PROGRESS__[%f/%t] "},
        );
        process = child;
        if (!controller.hasListener) child.kill();

        final output = StringBuffer();
        final errors = StringBuffer();
        var exitCode = 0;

        await Future.wait<void>([
          child.stdout
              .handleError((Object error, StackTrace stackTrace) {
                child.kill();
                Error.throwWithStackTrace(error, stackTrace);
              })
              .transform(const Utf8Decoder(allowMalformed: true))
              .transform(const LineSplitter())
              .forEach((line) {
                output.writeln(line);
                final progress = _parseProgress(line);
                if (progress != null && controller.hasListener) controller.add(progress);
              }),
          child.stderr
              .handleError((Object error, StackTrace stackTrace) {
                child.kill();
                Error.throwWithStackTrace(error, stackTrace);
              })
              .transform(const Utf8Decoder(allowMalformed: true))
              .forEach(errors.write),
          child.stdin.close(),
          child.exitCode.then((value) => exitCode = value),
        ]);

        if (exitCode != 0) {
          throw ProcessException(
            "ninja",
            arguments,
            "Aseprite compilation failed.\n$output\n$errors",
            exitCode,
          );
        }
      } catch (error, stackTrace) {
        process?.kill();
        if (controller.hasListener) controller.addError(error, stackTrace);
      } finally {
        controller.close();
      }
    });
  }

  CompilationProgress? _parseProgress(String line) {
    final match = _ninjaProgress.firstMatch(line);
    if (match == null) return null;

    final completed = int.tryParse(match[1]!);
    final total = int.tryParse(match[2]!);
    if (completed == null || total == null || total <= 0 || completed > total) return null;

    return CompilationProgress(completedTasks: completed, totalTasks: total);
  }

  Future<void> configure() async {
    if (!Platform.isLinux) {
      throw UnsupportedError("CMake configuration currently supports Linux only");
    }

    final sourceDirectory = checkout.absolute.path;
    final buildDirectory = build.absolute.path;
    final skiaDirectory = skia.absolute.path;

    final skiaLibraryDirectory = p.join(skiaDirectory, "out", "Release-x64");
    final skiaLibrary = p.join(skiaLibraryDirectory, "libskia.a");

    if (!await File(p.join(sourceDirectory, "CMakeLists.txt")).exists()) {
      throw StateError("Aseprite CMakeLists.txt not found in $sourceDirectory");
    }

    if (!await File(skiaLibrary).exists()) {
      throw StateError("Extracted Skia library not found: $skiaLibrary");
    }

    final arguments = [
      "-S",
      sourceDirectory,
      "-B",
      buildDirectory,
      "-G",
      "Ninja",
      "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
      "-DCMAKE_C_COMPILER=clang",
      "-DCMAKE_CXX_COMPILER=clang++",
      "-DCMAKE_CXX_FLAGS:STRING=-stdlib=libstdc++",
      "-DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libstdc++",
      "-DLAF_BACKEND=skia",
      "-DSKIA_DIR=$skiaDirectory",
      "-DSKIA_LIBRARY_DIR=$skiaLibraryDirectory",
      "-DSKIA_LIBRARY=$skiaLibrary",
    ];

    final result = await _runProcess("cmake", arguments);

    if (result.exitCode != 0) {
      throw ProcessException(
        "cmake",
        arguments,
        "Aseprite configuration failed.\n${result.stdout}\n${result.stderr}",
        result.exitCode,
      );
    }
  }
}
