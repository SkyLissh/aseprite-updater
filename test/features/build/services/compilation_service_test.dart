import "dart:async";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as p;

import "package:aseprite_updater/features/build/services/compilation_service.dart";

void main() {
  group("Linux configuration", () {
    late Directory temporary;
    late Directory checkout;
    late Directory build;
    late Directory skia;
    late File skiaLibrary;

    setUp(() async {
      temporary = await Directory.systemTemp.createTemp("updater configure ");
      checkout = await Directory(p.join(temporary.path, "source checkout")).create();
      build = Directory(p.join(temporary.path, "build output"));
      skia = Directory(p.join(temporary.path, "skia package"));
      skiaLibrary = File(p.join(skia.path, "out", "Release-x64", "libskia.a"));
      await skiaLibrary.parent.create(recursive: true);
      await skiaLibrary.create();
      await File(p.join(checkout.path, "CMakeLists.txt")).create();
    });

    tearDown(() async => temporary.delete(recursive: true));

    test("configures Ninja with absolute paths and Linux Skia settings", () async {
      final relativeCheckout = Directory(p.relative(checkout.path));
      final relativeBuild = Directory(p.relative(build.path));
      final relativeSkia = Directory(p.relative(skia.path));
      String? executable;
      List<String>? arguments;
      final service = CompilationService(
        checkout: relativeCheckout,
        build: relativeBuild,
        skia: relativeSkia,
        runProcess: (command, args) async {
          executable = command;
          arguments = args;
          return ProcessResult(1, 0, "configured", "");
        },
      );

      await service.configure();

      final skiaDirectory = relativeSkia.absolute.path;
      final libraryDirectory = p.join(skiaDirectory, "out", "Release-x64");
      expect(executable, "cmake");
      expect(arguments, [
        "-S",
        relativeCheckout.absolute.path,
        "-B",
        relativeBuild.absolute.path,
        "-G",
        "Ninja",
        "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
        "-DCMAKE_C_COMPILER=clang",
        "-DCMAKE_CXX_COMPILER=clang++",
        "-DCMAKE_CXX_FLAGS:STRING=-stdlib=libstdc++",
        "-DCMAKE_EXE_LINKER_FLAGS:STRING=-stdlib=libstdc++",
        "-DLAF_BACKEND=skia",
        "-DSKIA_DIR=$skiaDirectory",
        "-DSKIA_LIBRARY_DIR=$libraryDirectory",
        "-DSKIA_LIBRARY=${p.join(libraryDirectory, "libskia.a")}",
      ]);
    });

    test("waits for CMake to finish before completing", () async {
      final started = Completer<void>();
      final result = Completer<ProcessResult>();
      var completed = false;
      final service = CompilationService(
        checkout: checkout,
        build: build,
        skia: skia,
        runProcess: (_, _) {
          started.complete();
          return result.future;
        },
      );

      final done = service.configure().then((_) => completed = true);
      await started.future;
      expect(completed, isFalse);

      result.complete(ProcessResult(1, 0, "", ""));
      await done;
      expect(completed, isTrue);
    });

    for (final missing in ["CMakeLists.txt", "libskia.a"]) {
      test("rejects missing $missing before invoking CMake", () async {
        final file = missing == "CMakeLists.txt"
            ? File(p.join(checkout.path, missing))
            : skiaLibrary;
        await file.delete();
        var invoked = false;
        final service = CompilationService(
          checkout: checkout,
          build: build,
          skia: skia,
          runProcess: (_, _) async {
            invoked = true;
            return ProcessResult(1, 0, "", "");
          },
        );

        await expectLater(
          service.configure(),
          throwsA(isA<StateError>().having((error) => error.message, "message", contains(missing))),
        );
        expect(invoked, isFalse);
      });
    }

    test("preserves CMake diagnostics and exit code on failure", () async {
      final service = CompilationService(
        checkout: checkout,
        build: build,
        skia: skia,
        runProcess: (_, _) async {
          return ProcessResult(1, 7, "compiler detection failed", "missing X11 headers");
        },
      );

      await expectLater(
        service.configure(),
        throwsA(
          isA<ProcessException>()
              .having((error) => error.executable, "executable", "cmake")
              .having(
                (error) => error.arguments,
                "arguments",
                containsAllInOrder(["-S", checkout.absolute.path, "-B", build.absolute.path]),
              )
              .having((error) => error.errorCode, "exit code", 7)
              .having((error) => error.message, "stdout", contains("compiler detection failed"))
              .having((error) => error.message, "stderr", contains("missing X11 headers")),
        ),
      );
    });

    test("propagates process startup errors unchanged", () async {
      const error = ProcessException("cmake", [], "executable not found");
      final service = CompilationService(
        checkout: checkout,
        build: build,
        skia: skia,
        runProcess: (_, _) async => throw error,
      );

      await expectLater(service.configure(), throwsA(same(error)));
    });
  }, skip: !Platform.isLinux);

  test("rejects unsupported platforms before invoking CMake", () async {
    var invoked = false;
    final service = CompilationService(
      checkout: Directory.systemTemp,
      build: Directory.systemTemp,
      skia: Directory.systemTemp,
      runProcess: (_, _) async {
        invoked = true;
        return ProcessResult(1, 0, "", "");
      },
    );

    await expectLater(service.configure(), throwsUnsupportedError);
    expect(invoked, isFalse);
  }, skip: Platform.isLinux);
}
