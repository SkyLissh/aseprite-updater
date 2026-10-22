import "dart:async";
import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/services.dart";

void main() {
  late Directory temporary;
  setUp(() async => temporary = await Directory.systemTemp.createTemp("updater-orchestrator-"));
  tearDown(() async => temporary.delete(recursive: true));

  test("cloning stays indeterminate until the source finishes", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final releaseClone = Completer<void>();
    final source = _ControlledSource(paths.checkout, (tag) async {
      expect(tag, "v1");
      expect(await paths.out.exists(), isTrue);
      await releaseClone.future;
    });
    final events = <BuildEvent>[];
    final done = OrchestratorService(paths, source).run(tag: "v1").forEach(events.add);
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
      ).run(tag: "v1").forEach(events.add),
      throwsA(isA<FileSystemException>()),
    );
    expect(cloned, isFalse);
    expect(events, hasLength(1));
    expect(events.whereType<BuildCompleted>(), isEmpty);
  });

  test("source validation rejects blank tags and existing destinations", () async {
    await expectLater(SourceService(temporary).clone(tag: "  "), throwsArgumentError);
    await expectLater(SourceService(temporary).clone(tag: "v1"), throwsStateError);
  });

  test("a source failure propagates without deployment or completion", () async {
    final paths = PathsService(Directory("${temporary.path}/workspace"));
    final source = _ControlledSource(paths.checkout, (_) async {
      throw StateError("clone failed");
    });
    final events = <BuildEvent>[];

    await expectLater(
      OrchestratorService(paths, source).run(tag: "v1").forEach(events.add),
      throwsStateError,
    );
    expect(events, hasLength(2));
    expect(events.whereType<BuildCompleted>(), isEmpty);
    expect((events.last as StepChanged).step, const BuildStep.cloning());
  });
}

class _ControlledSource(super.checkout, final Future<void> Function(String) action)
    extends SourceService {
  @override
  Future<void> clone({required String tag}) => action(tag);
}
