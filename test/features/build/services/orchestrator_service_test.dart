import "dart:async";
import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/core/services/paths_service.dart";
import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/services.dart";

void main() {
  late Directory temporary;
  late _ControlledCompilation compilation;
  late _ControlledInstallation installation;
  setUp(() async {
    temporary = await Directory.systemTemp.createTemp("updater-orchestrator-");
    compilation = _ControlledCompilation(PathsService(temporary));
    installation = _ControlledInstallation(PathsService(temporary));
  });
  tearDown(() async => temporary.delete(recursive: true));

  test("integration failure is reported after installation and still completes", () async {
    final paths = PathsService(temporary);
    final order = <String>[];
    final errors = <Object>[];
    final failure = StateError("integration failed");
    final events = await OrchestratorService(
      paths,
      _ControlledSource(paths.checkout, (_) async {}),
      _ControlledSkia(paths.skia),
      compilation,
      _ControlledInstallation(
        paths,
        action: () async {
          order.add("installation");
        },
      ),
      _ControlledIntegration(
        paths,
        action: () async {
          order.add("integration");
          throw failure;
        },
      ),
      onIntegrationError: (error, stackTrace) => errors.add(error),
    ).run(tag: "v1", operation: .install).toList();

    expect(order, ["installation", "integration"]);
    expect(errors, [failure]);
    expect(events.last, isA<BuildCompleted>());
  });

  test("installation failure prevents integration and completion", () async {
    final paths = PathsService(temporary);
    var integrated = false;
    final failure = StateError("installation failed");
    final events = <BuildEvent>[];

    await expectLater(
      OrchestratorService(
        paths,
        _ControlledSource(paths.checkout, (_) async {}),
        _ControlledSkia(paths.skia),
        compilation,
        _ControlledInstallation(paths, action: () async => throw failure),
        _ControlledIntegration(
          paths,
          action: () async {
            integrated = true;
          },
        ),
      ).run(tag: "v1", operation: .install).forEach(events.add),
      throwsA(same(failure)),
    );

    expect(integrated, isFalse);
    expect(events.whereType<BuildCompleted>(), isEmpty);
  });

  for (final cachedTag in <String?>[null, "older-skia", "test-skia"]) {
    test("cached Skia tag $cachedTag controls downloading and extraction", () async {
      final paths = PathsService(temporary);
      final skia = _ControlledSkia(paths.skia, cachedTag: cachedTag);
      final events = await OrchestratorService(
        paths,
        _ControlledSource(paths.checkout, (_) async {}),
        skia,
        compilation,
        installation,
        _ControlledIntegration(PathsService(temporary)),
      ).run(tag: "v1", operation: .install).toList();

      if (cachedTag == "test-skia") {
        expect(skia.downloadTags, isEmpty);
        expect(skia.extractionTags, isEmpty);
        expect(events.whereType<StepChanged>().map((event) => event.step), [
          const BuildStep.preparing(),
          const BuildStep.cloning(),
          const BuildStep.configuring(),
          const BuildStep.compiling(completedTasks: 0),
          const BuildStep.deploying(),
        ]);
      } else {
        expect(skia.downloadTags, ["test-skia"]);
        expect(skia.extractionTags, ["test-skia"]);
        expect(
          events.whereType<StepChanged>().map((event) => event.step),
          containsAllInOrder([
            const BuildStep.downloadingSkia(receivedBytes: 0),
            const BuildStep.extractingSkia(completedFiles: 0),
            const BuildStep.configuring(),
          ]),
        );
      }

      expect(events.last, isA<BuildCompleted>());
      expect(installation.tags, ["v1"]);
    });
  }

  test("update prepares existing source without cloning", () async {
    final paths = PathsService(temporary);
    final source = _UpdateSource(paths.checkout);
    final events = await OrchestratorService(
      paths,
      source,
      _ControlledSkia(paths.skia),
      compilation,
      installation,
      _ControlledIntegration(PathsService(temporary)),
    ).run(tag: "v2", operation: .update).toList();

    expect(source.tags, ["v2"]);
    expect(events.last, isA<BuildCompleted>());
    expect(installation.tags, ["v2"]);
  });

  test("cloning stays indeterminate until the source finishes", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final releaseClone = Completer<void>();
    final source = _ControlledSource(paths.checkout, (tag) async {
      expect(tag, "v1");
      expect(await paths.out.exists(), isTrue);
      await releaseClone.future;
    });
    final events = <BuildEvent>[];
    final done = OrchestratorService(
      paths,
      source,
      _ControlledSkia(paths.skia),
      compilation,
      installation,
      _ControlledIntegration(PathsService(temporary)),
    ).run(tag: "v1", operation: .install).forEach(events.add);
    while (events.length < 2) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(events.whereType<StepChanged>().map((event) => event.step), [
      const BuildStep.preparing(),
      const BuildStep.cloning(),
    ]);
    expect(events.whereType<BuildCompleted>(), isEmpty);

    releaseClone.complete();
    await done;
    expect(events.whereType<StepChanged>().map((event) => event.step), [
      const BuildStep.preparing(),
      const BuildStep.cloning(),
      const BuildStep.downloadingSkia(receivedBytes: 0),
      const BuildStep.extractingSkia(completedFiles: 0),
      const BuildStep.configuring(),
      const BuildStep.compiling(completedTasks: 0),
      const BuildStep.deploying(),
    ]);
    expect(events.last, isA<BuildCompleted>());
  });

  test("workspace failure prevents cloning and completion", () async {
    final blocker = await File("${temporary.path}/blocked").create();
    var cloned = false;
    final source = _ControlledSource(temporary, (_) async {
      cloned = true;
    });
    final events = <BuildEvent>[];
    await expectLater(
      OrchestratorService(
        PathsService(Directory(blocker.path)),
        source,
        _ControlledSkia(temporary),
        compilation,
        installation,
        _ControlledIntegration(PathsService(temporary)),
      ).run(tag: "v1", operation: .install).forEach(events.add),
      throwsA(isA<FileSystemException>()),
    );
    expect(cloned, isFalse);
    expect(compilation.calls, 0);
    expect(compilation.compileCalls, 0);
    expect(events, hasLength(1));
    expect(events.whereType<BuildCompleted>(), isEmpty);
  });

  test("source validation rejects blank tags and existing destinations", () async {
    await expectLater(SourceService(temporary).clone(tag: "  "), throwsArgumentError);
    await expectLater(SourceService(temporary).clone(tag: "v1"), throwsStateError);
  });

  test("a source failure propagates without installation or completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final source = _ControlledSource(paths.checkout, (_) async {
      throw StateError("clone failed");
    });
    final events = <BuildEvent>[];

    await expectLater(
      OrchestratorService(
        paths,
        source,
        _ControlledSkia(paths.skia),
        compilation,
        installation,
        _ControlledIntegration(PathsService(temporary)),
      ).run(tag: "v1", operation: .install).forEach(events.add),
      throwsStateError,
    );
    expect(events, hasLength(2));
    expect(compilation.calls, 0);
    expect(compilation.compileCalls, 0);
    expect(events.whereType<BuildCompleted>(), isEmpty);
    expect((events.last as StepChanged).step, const BuildStep.cloning());
  });

  test("forwards Skia progress and waits for the download before completing", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final source = _ControlledSource(paths.checkout, (_) async {});
    final progress = StreamController<DownloadProgress>();
    addTearDown(progress.close);
    final events = <BuildEvent>[];
    final done = OrchestratorService(
      paths,
      source,
      _ControlledSkia(paths.skia, progress: progress.stream),
      compilation,
      installation,
      _ControlledIntegration(PathsService(temporary)),
    ).run(tag: "v1", operation: .install).forEach(events.add);
    progress.add(const DownloadProgress(receivedBytes: 50, totalBytes: 100));
    while (events.length < 4) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(
      (events.last as StepChanged).step,
      const BuildStep.downloadingSkia(receivedBytes: 50, totalBytes: 100),
    );
    expect(events.whereType<BuildCompleted>(), isEmpty);

    await progress.close();
    await done;

    expect(events.last, isA<BuildCompleted>());
  });

  test("a Skia failure propagates without installation or completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final source = _ControlledSource(paths.checkout, (_) async {});
    final events = <BuildEvent>[];

    await expectLater(
      OrchestratorService(
        paths,
        source,
        _ControlledSkia(paths.skia, progress: Stream.error(StateError("download failed"))),
        compilation,
        installation,
        _ControlledIntegration(PathsService(temporary)),
      ).run(tag: "v1", operation: .install).forEach(events.add),
      throwsStateError,
    );
    expect(events.whereType<BuildCompleted>(), isEmpty);
    expect((events.last as StepChanged).step, const BuildStep.downloadingSkia(receivedBytes: 0));
    expect(compilation.calls, 0);
    expect(compilation.compileCalls, 0);
  });

  test("forwards extraction progress and waits before completing", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final progress = StreamController<ExtractingProgress>();
    addTearDown(progress.close);
    final events = <BuildEvent>[];
    final done = OrchestratorService(
      paths,
      _ControlledSource(paths.checkout, (_) async {}),
      _ControlledSkia(paths.skia, extraction: progress.stream),
      compilation,
      installation,
      _ControlledIntegration(PathsService(temporary)),
    ).run(tag: "v1", operation: .install).forEach(events.add);
    progress.add(const ExtractingProgress(completedFiles: 1, totalFiles: 2));
    while (events.length < 5) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(
      (events.last as StepChanged).step,
      const BuildStep.extractingSkia(completedFiles: 1, totalFiles: 2),
    );
    expect(compilation.calls, 0);
    expect(events.whereType<BuildCompleted>(), isEmpty);

    await progress.close();
    await done;

    expect(events.last, isA<BuildCompleted>());
  });

  test("an extraction failure prevents installation and completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final events = <BuildEvent>[];

    await expectLater(
      OrchestratorService(
        paths,
        _ControlledSource(paths.checkout, (_) async {}),
        _ControlledSkia(paths.skia, extraction: Stream.error(StateError("extraction failed"))),
        compilation,
        installation,
        _ControlledIntegration(PathsService(temporary)),
      ).run(tag: "v1", operation: .install).forEach(events.add),
      throwsStateError,
    );
    expect(events.whereType<BuildCompleted>(), isEmpty);
    expect((events.last as StepChanged).step, const BuildStep.extractingSkia(completedFiles: 0));
    expect(compilation.calls, 0);
    expect(compilation.compileCalls, 0);
  });

  test("configures after extraction and waits before installation and completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final extraction = StreamController<ExtractingProgress>();
    addTearDown(extraction.close);
    final started = Completer<void>();
    final releaseConfiguration = Completer<void>();
    compilation = _ControlledCompilation(
      paths,
      action: () {
        started.complete();
        return releaseConfiguration.future;
      },
    );
    final events = <BuildEvent>[];
    final done = OrchestratorService(
      paths,
      _ControlledSource(paths.checkout, (_) async {}),
      _ControlledSkia(paths.skia, extraction: extraction.stream),
      compilation,
      installation,
      _ControlledIntegration(PathsService(temporary)),
    ).run(tag: "v1", operation: .install).forEach(events.add);
    extraction.add(const ExtractingProgress(completedFiles: 1, totalFiles: 1));
    while (events.length < 5) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(compilation.calls, 0);

    await extraction.close();
    await started.future;

    final steps = events.whereType<StepChanged>().map((event) => event.step).toList();
    expect(steps.last, const BuildStep.configuring());
    expect(steps.last.fraction, isNull);
    expect(steps.whereType<Deploying>(), isEmpty);
    expect(compilation.compileCalls, 0);
    expect(events.whereType<BuildCompleted>(), isEmpty);

    releaseConfiguration.complete();
    await done;

    expect(compilation.calls, 1);
    expect(events.whereType<StepChanged>().map((event) => event.step), [
      const BuildStep.preparing(),
      const BuildStep.cloning(),
      const BuildStep.downloadingSkia(receivedBytes: 0),
      const BuildStep.extractingSkia(completedFiles: 0),
      const BuildStep.extractingSkia(completedFiles: 1, totalFiles: 1),
      const BuildStep.configuring(),
      const BuildStep.compiling(completedTasks: 0),
      const BuildStep.deploying(),
    ]);
    expect(events.last, isA<BuildCompleted>());
  });

  test("a configuration failure prevents installation and completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    const error = ProcessException("cmake", [], "configuration failed", 1);
    compilation = _ControlledCompilation(paths, action: () async => throw error);
    final events = <BuildEvent>[];

    await expectLater(
      OrchestratorService(
        paths,
        _ControlledSource(paths.checkout, (_) async {}),
        _ControlledSkia(paths.skia),
        compilation,
        installation,
        _ControlledIntegration(PathsService(temporary)),
      ).run(tag: "v1", operation: .install).forEach(events.add),
      throwsA(same(error)),
    );

    expect(compilation.calls, 1);
    expect(compilation.compileCalls, 0);
    expect((events.last as StepChanged).step, const BuildStep.configuring());
    expect(
      events.whereType<StepChanged>().map((event) => event.step).whereType<Deploying>(),
      isEmpty,
    );
    expect(events.whereType<BuildCompleted>(), isEmpty);
  });

  test("forwards compilation counters and waits before installation and completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final progress = StreamController<CompilationProgress>();
    addTearDown(progress.close);
    compilation = _ControlledCompilation(paths, progress: progress.stream);
    final events = <BuildEvent>[];
    final done = OrchestratorService(
      paths,
      _ControlledSource(paths.checkout, (_) async {}),
      _ControlledSkia(paths.skia),
      compilation,
      installation,
      _ControlledIntegration(PathsService(temporary)),
    ).run(tag: "v1", operation: .install).forEach(events.add);
    progress.add(const CompilationProgress(completedTasks: 3, totalTasks: 4));
    while (events.length < 7) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(compilation.calls, 1);
    expect(compilation.compileCalls, 1);
    final steps = events.whereType<StepChanged>().map((event) => event.step).toList();
    expect(steps[5], const BuildStep.compiling(completedTasks: 0));
    expect(steps[5].fraction, isNull);
    expect(steps.last, const BuildStep.compiling(completedTasks: 3, totalTasks: 4));
    expect(steps.last.fraction, .75);
    expect(steps.whereType<Deploying>(), isEmpty);
    expect(events.whereType<BuildCompleted>(), isEmpty);
    expect(installation.calls, 0);

    await progress.close();
    await done;
    expect(installation.calls, 1);
    expect(installation.tags, ["v1"]);
    expect((events[events.length - 2] as StepChanged).step, const BuildStep.deploying());
    expect(events.last, isA<BuildCompleted>());
  });

  test("a compilation failure prevents installation and completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    const error = ProcessException("ninja", [], "compilation failed", 1);
    compilation = _ControlledCompilation(paths, progress: Stream.error(error));
    final events = <BuildEvent>[];

    await expectLater(
      OrchestratorService(
        paths,
        _ControlledSource(paths.checkout, (_) async {}),
        _ControlledSkia(paths.skia),
        compilation,
        installation,
        _ControlledIntegration(PathsService(temporary)),
      ).run(tag: "v1", operation: .install).forEach(events.add),
      throwsA(same(error)),
    );

    expect(compilation.compileCalls, 1);
    expect(installation.calls, 0);
    expect((events.last as StepChanged).step, const BuildStep.compiling(completedTasks: 0));
    expect(
      events.whereType<StepChanged>().map((event) => event.step).whereType<Deploying>(),
      isEmpty,
    );
    expect(events.whereType<BuildCompleted>(), isEmpty);
  });

  test("installation starts after compilation and prevents completion while pending", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final progress = StreamController<CompilationProgress>();
    addTearDown(progress.close);
    compilation = _ControlledCompilation(paths, progress: progress.stream);
    final started = Completer<void>();
    final releaseDeployment = Completer<void>();
    addTearDown(() {
      if (!releaseDeployment.isCompleted) releaseDeployment.complete();
    });
    installation = _ControlledInstallation(
      paths,
      action: () {
        started.complete();
        return releaseDeployment.future;
      },
    );
    final events = <BuildEvent>[];
    final done = OrchestratorService(
      paths,
      _ControlledSource(paths.checkout, (_) async {}),
      _ControlledSkia(paths.skia),
      compilation,
      installation,
      _ControlledIntegration(PathsService(temporary)),
    ).run(tag: "v1", operation: .install).forEach(events.add);
    while (compilation.compileCalls == 0) {
      await Future<void>.delayed(Duration.zero);
    }

    expect(installation.calls, 0);
    await progress.close();
    await started.future.timeout(const Duration(seconds: 2));

    expect(installation.calls, 1);
    expect(installation.tags, ["v1"]);
    expect((events.last as StepChanged).step, const BuildStep.deploying());
    expect((events.last as StepChanged).step.fraction, isNull);
    expect(events.whereType<BuildCompleted>(), isEmpty);

    releaseDeployment.complete();
    await done;

    expect(events.last, isA<BuildCompleted>());
  });

  test("a installation failure propagates without completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final error = StateError("installation failed");
    installation = _ControlledInstallation(paths, action: () async => throw error);
    final events = <BuildEvent>[];

    await expectLater(
      OrchestratorService(
        paths,
        _ControlledSource(paths.checkout, (_) async {}),
        _ControlledSkia(paths.skia),
        compilation,
        installation,
        _ControlledIntegration(PathsService(temporary)),
      ).run(tag: "v1", operation: .install).forEach(events.add),
      throwsA(same(error)),
    );

    expect(installation.calls, 1);
    expect(installation.tags, ["v1"]);
    expect((events.last as StepChanged).step, const BuildStep.deploying());
    expect(events.whereType<BuildCompleted>(), isEmpty);
  });
}

class _ControlledSource(super.checkout, final Future<void> Function(String) action)
    extends SourceService {
  @override
  Future<String> requiredSkia() async => "test-skia";

  @override
  Future<void> clone({required String tag}) => action(tag);
}

class _UpdateSource(super.checkout) extends SourceService {
  final tags = <String>[];

  @override
  Future<String> requiredSkia() async => "test-skia";

  @override
  Future<void> clone({required String tag}) async => throw StateError("Update must not clone");

  @override
  Future<void> update({required String tag}) async {
    tags.add(tag);
  }
}

class _ControlledSkia(
  super.directory, {
  final String? cachedTag,
  final Stream<DownloadProgress> progress = const Stream.empty(),
  final Stream<ExtractingProgress> extraction = const Stream.empty(),
}) extends SkiaService {
  final downloadTags = <String>[];
  final extractionTags = <String>[];

  @override
  Future<String?> installedTag() async => cachedTag;

  @override
  Stream<DownloadProgress> download({required String releaseTag}) {
    downloadTags.add(releaseTag);
    return progress;
  }

  @override
  Stream<ExtractingProgress> extract({required String releaseTag}) {
    extractionTags.add(releaseTag);
    return extraction;
  }
}

class _ControlledCompilation(
  PathsService paths, {
  final Future<void> Function()? action,
  final Stream<CompilationProgress> progress = const Stream.empty(),
}) extends CompilationService {
  this : super(checkout: paths.checkout, build: paths.build, skia: paths.skia);

  var calls = 0;
  var compileCalls = 0;

  @override
  Future<void> configure() {
    calls++;
    return action?.call() ?? Future<void>.value();
  }

  @override
  Stream<CompilationProgress> compile() {
    compileCalls++;
    return progress;
  }
}

class _ControlledInstallation(PathsService paths, {final Future<void> Function()? action})
    extends InstallationService {
  this
    : super(
        build: paths.build,
        installation: paths.installation,
        stagingInstallation: paths.stagingInstallation,
      );

  var calls = 0;
  final tags = <String>[];

  @override
  Future<void> install({required String tag}) {
    tags.add(tag);
    calls++;
    return action?.call() ?? Future<void>.value();
  }
}

class _ControlledIntegration(PathsService paths, {final Future<void> Function()? action})
    extends DesktopIntegrationService {
  this
    : super(
        checkout: paths.checkout,
        installation: paths.installation,
        desktopEntry: paths.desktopEntry,
        icon: paths.icon,
        commandLink: paths.commandLink,
      );

  @override
  Future<void> ensure() => action?.call() ?? Future<void>.value();
}
