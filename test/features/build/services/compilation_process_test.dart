import "dart:async";
import "dart:convert";
import "dart:io";

import "package:flutter_test/flutter_test.dart";
import "package:path/path.dart" as p;

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/compilation_service.dart";

void main() {
  group("Linux compilation", () {
    late Directory temporary;
    late Directory build;
    late _ControlledProcess process;
    late Completer<void> started;
    late CompilationService service;
    String? executable;
    List<String>? arguments;
    Map<String, String>? processEnvironment;

    setUp(() async {
      temporary = await Directory.systemTemp.createTemp("updater compilation ");
      build = await Directory(p.join(temporary.path, "build output")).create();
      await File(p.join(build.path, "build.ninja")).create();
      process = _ControlledProcess();
      started = Completer<void>();
      executable = null;
      arguments = null;
      processEnvironment = null;
      service = CompilationService(
        checkout: temporary,
        build: Directory(p.relative(build.path)),
        skia: temporary,
        startProcess: (command, args, {environment}) async {
          executable = command;
          arguments = args;
          processEnvironment = environment;
          started.complete();
          return process;
        },
      );
    });

    tearDown(() async {
      await process.dispose();
      await temporary.delete(recursive: true);
    });

    test("starts Ninja with an absolute build path and marked task counters", () async {
      final done = service.compile().drain<void>();
      await started.future;
      await process.finish();
      await done;

      expect(executable, "ninja");
      expect(arguments, ["-C", Directory(p.relative(build.path)).absolute.path, "aseprite"]);
      expect(processEnvironment, {"NINJA_STATUS": "__ASEPRITE_PROGRESS__[%f/%t] "});
      expect(process.stdinClosed, isTrue);
    });

    test("streams measured progress before Ninja exits", () async {
      final updates = <CompilationProgress>[];
      final first = Completer<void>();
      var completed = false;
      final done = service
          .compile()
          .forEach((progress) {
            updates.add(progress);
            if (!first.isCompleted) first.complete();
          })
          .then((_) => completed = true);
      await started.future;

      process.output.add(utf8.encode("__ASEPRITE_PROGRESS__[0/4] starting\n"));
      await first.future;
      expect(updates.single.completedTasks, 0);
      expect(updates.single.totalTasks, 4);
      expect(completed, isFalse);

      process.output.add(utf8.encode("__ASEPRITE_PROGRESS__[3/4] compiling\n"));
      process.output.add(utf8.encode("__ASEPRITE_PROGRESS__[4/4] linking\n"));
      await process.finish();
      await done;
      expect(updates.map((value) => (value.completedTasks, value.totalTasks)), [
        (0, 4),
        (3, 4),
        (4, 4),
      ]);
      expect(completed, isTrue);
    });

    test("parses split bytes, CR/LF lines and an unterminated final update", () async {
      final done = service.compile().toList();
      await started.future;
      final bytes = utf8.encode(
        "compiler: café\n__ASEPRITE_PROGRESS__[1/4] compile\r"
        "__ASEPRITE_PROGRESS__[2/4] compile\r\n__ASEPRITE_PROGRESS__[4/4] link",
      );
      for (final byte in bytes) {
        process.output.add([byte]);
      }
      await process.finish();

      expect((await done).map((value) => value.completedTasks), [1, 2, 4]);
    });

    test("ignores unrelated and invalid counters while accepting duplicate updates", () async {
      final done = service.compile().toList();
      await started.future;
      process.output.add(
        utf8.encode(
          "[1/4] compiler output\nwarning: __ASEPRITE_PROGRESS__[1/4] quoted\n"
          "__ASEPRITE_PROGRESS__[bad/4] invalid\n__ASEPRITE_PROGRESS__[-1/4] invalid\n"
          "__ASEPRITE_PROGRESS__[1/0] invalid\n__ASEPRITE_PROGRESS__[5/4] invalid\n"
          "__ASEPRITE_PROGRESS__[1/4] valid\n__ASEPRITE_PROGRESS__[1/4] duplicate\n",
        ),
      );
      process.errors.add([0xff]);
      await process.finish();

      expect((await done).map((value) => (value.completedTasks, value.totalTasks)), [
        (1, 4),
        (1, 4),
      ]);
    });

    test("waits for both output streams after the process exits", () async {
      var completed = false;
      final done = service.compile().drain<void>().then((_) => completed = true);
      await started.future;
      process.exit.complete(0);
      await process.output.close();
      await Future<void>.delayed(Duration.zero);
      expect(completed, isFalse);

      process.errors.add(utf8.encode("late stderr\n"));
      await process.errors.close();
      await done;
      expect(completed, isTrue);
    });

    test("rejects an unconfigured build before starting Ninja", () async {
      await File(p.join(build.path, "build.ninja")).delete();

      await expectLater(service.compile().drain<void>(), throwsStateError);
      expect(started.isCompleted, isFalse);
    });

    test("propagates startup failures unchanged", () async {
      const error = ProcessException("ninja", [], "executable not found");
      service = CompilationService(
        checkout: temporary,
        build: build,
        skia: temporary,
        startProcess: (_, _, {environment}) async => throw error,
      );

      await expectLater(service.compile().drain<void>(), throwsA(same(error)));
    });

    test("preserves failure diagnostics even after the final task update", () async {
      final updates = <CompilationProgress>[];
      final failure = expectLater(
        service.compile().forEach(updates.add),
        throwsA(
          isA<ProcessException>()
              .having((value) => value.executable, "executable", "ninja")
              .having(
                (value) => value.arguments,
                "arguments",
                containsAllInOrder(["-C", "aseprite"]),
              )
              .having((value) => value.errorCode, "exit code", 7)
              .having((value) => value.message, "stdout", contains("linking failed"))
              .having((value) => value.message, "stderr", contains("undefined symbol")),
        ),
      );
      await started.future;
      process.output.add(utf8.encode("__ASEPRITE_PROGRESS__[4/4] linking failed\n"));
      process.errors.add(utf8.encode("undefined symbol\n"));
      await process.finish(7);
      await failure;
      expect(updates.single.completedTasks, 4);
    });

    test("succeeds without invented progress when no work is needed", () async {
      final done = service.compile().toList();
      await started.future;
      process.output.add(utf8.encode("ninja: no work to do.\n"));
      await process.finish();
      expect(await done, isEmpty);
    });

    test("an output read failure terminates the child and propagates the error", () async {
      final error = StateError("stdout read failed");
      final failed = expectLater(service.compile().drain<void>(), throwsA(same(error)));
      await started.future;
      process.output.addError(error);
      await Future<void>.delayed(Duration.zero);
      expect(process.killed, isTrue);
      await failed;
    });

    test("cancelling progress requests termination and cleanup finishes separately", () async {
      final subscription = service.compile().listen((_) {});
      await process.stdoutStarted.future;
      await subscription.cancel();

      expect(process.killed, isTrue);
      await Future.wait<Object?>([
        process.exit.future,
        process.output.done,
        process.errors.done,
        process.stdin.done,
      ]);
      expect(process.stdoutRead, isTrue);
      expect(process.stderrRead, isTrue);
      expect(process.stdinClosed, isTrue);
      expect(process.exit.isCompleted, isTrue);
    });

    test("cancellation completes before pending startup and cleanup finish", () async {
      final launch = Completer<Process>();
      service = CompilationService(
        checkout: temporary,
        build: build,
        skia: temporary,
        startProcess: (_, _, {environment}) {
          started.complete();
          return launch.future;
        },
      );
      final subscription = service.compile().listen((_) {});
      await started.future;

      await subscription.cancel();
      expect(process.killed, isFalse);

      launch.complete(process);
      await Future.wait<Object?>([
        process.exit.future,
        process.output.done,
        process.errors.done,
        process.stdin.done,
      ]);
      expect(process.killed, isTrue);
      expect(process.stdoutRead, isTrue);
      expect(process.stderrRead, isTrue);
      expect(process.stdinClosed, isTrue);
    });
  }, skip: !Platform.isLinux);

  test("compilation rejects unsupported platforms", () async {
    var invoked = false;
    final service = CompilationService(
      checkout: Directory.systemTemp,
      build: Directory.systemTemp,
      skia: Directory.systemTemp,
      startProcess: (_, _, {environment}) async {
        invoked = true;
        throw StateError("unexpected process launch");
      },
    );
    await expectLater(service.compile().drain<void>(), throwsUnsupportedError);
    expect(invoked, isFalse);
  }, skip: Platform.isLinux);
}

class _ControlledProcess implements Process {
  final output = StreamController<List<int>>();
  final errors = StreamController<List<int>>();
  final exit = Completer<int>();
  final stdoutStarted = Completer<void>();
  var stdinClosed = false;
  var stdoutRead = false;
  var stderrRead = false;
  var killed = false;

  @override
  late final IOSink stdin;

  new() {
    output.onListen = stdoutStarted.complete;
    final input = StreamController<List<int>>();
    input.stream.listen((_) {}, onDone: () => stdinClosed = true);
    stdin = IOSink(input.sink);
  }

  @override
  Stream<List<int>> get stdout {
    stdoutRead = true;
    return output.stream;
  }

  @override
  Stream<List<int>> get stderr {
    stderrRead = true;
    return errors.stream;
  }

  @override
  Future<int> get exitCode => exit.future;

  @override
  int get pid => 1;

  @override
  bool kill([ProcessSignal signal = ProcessSignal.sigterm]) {
    killed = true;
    unawaited(finish(-15));
    return true;
  }

  Future<void> finish([int code = 0]) async {
    if (!exit.isCompleted) exit.complete(code);
    await Future.wait([output.close(), errors.close()]);
  }

  Future<void> dispose() async {
    if (!stdoutRead) unawaited(stdout.drain<void>());
    if (!stderrRead) unawaited(stderr.drain<void>());
    await finish();
    await stdin.close();
  }
}
