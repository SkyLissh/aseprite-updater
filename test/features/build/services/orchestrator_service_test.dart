import "dart:async";
import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/services.dart";

void main() {
  late Directory temporary;
  setUp(() async => temporary = await Directory.systemTemp.createTemp("updater-orchestrator-"));
  tearDown(() async => temporary.delete(recursive: true));

  test("workspace preparation finishes before cloning; Git progress maps to build steps", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final releaseClone = Completer<void>();
    const progress = GitProgress(operation: .downloadingSource, progress: .5);
    final source = _ControlledSource(paths.checkout, (tag) async* {
      expect(tag, "v1");
      expect(await paths.out.exists(), isTrue);
      await releaseClone.future;
      yield progress;
    });
    final events = <BuildEvent>[];
    final done = OrchestratorService(paths, source).run(tag: "v1").forEach(events.add);
    while (!events.any((event) => event is StepChanged && event.step is Cloning)) {
      await Future<void>.delayed(Duration.zero);
    }
    expect(
      events.first,
      isA<StepChanged>().having((event) => event.step, "step", const BuildStep.preparing()),
    );
    expect(events, hasLength(2));
    releaseClone.complete();
    await done;
    expect(
      events[2],
      isA<StepChanged>().having(
        (event) => event.step,
        "step",
        const BuildStep.cloning(operation: .downloadingSource, progress: .5),
      ),
    );
    expect(
      events[3],
      isA<StepChanged>().having((event) => event.step, "step", const BuildStep.deploying()),
    );
    expect(events.last, isA<BuildCompleted>());
  });

  test("workspace failure prevents cloning and completion", () async {
    final blocker = await File("${temporary.path}/blocked").create();
    var cloned = false;
    final source = _ControlledSource(temporary, (_) async* {
      cloned = true;
    });
    final events = <BuildEvent>[];
    await expectLater(
      OrchestratorService(
        PathsService(Directory(blocker.path)),
        source,
      ).run(tag: "v1").forEach(events.add),
      throwsA(isA<FileSystemException>()),
    );
    expect(cloned, isFalse);
    expect(events, hasLength(1));
    expect(events.whereType<BuildCompleted>(), isEmpty);
  });

  test("source validation rejects blank tags and existing destinations", () async {
    await expectLater(SourceService(temporary).clone(tag: "  "), emitsError(isArgumentError));
    await expectLater(SourceService(temporary).clone(tag: "v1"), emitsError(isStateError));
  });

  test("a source failure propagates without deployment or completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final source = _ControlledSource(paths.checkout, (_) async* {
      yield const GitProgress(operation: .downloadingSource, progress: 1);
      throw StateError("clone failed");
    });
    final events = <BuildEvent>[];

    await expectLater(
      OrchestratorService(paths, source).run(tag: "v1").forEach(events.add),
      throwsA(isStateError),
    );
    expect(events, hasLength(3));
    expect(events.whereType<BuildCompleted>(), isEmpty);
    expect(
      (events.last as StepChanged).step,
      const BuildStep.cloning(operation: .downloadingSource, progress: 1),
    );
  });
}

class _ControlledSource extends SourceService {
  final Stream<GitProgress> Function(String) events;

  new(super.checkout, this.events);

  @override
  Stream<GitProgress> clone({required String tag}) => events(tag);
}
