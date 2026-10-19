import "dart:async";
import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/services.dart";

void main() {
  late Directory temporary;
  setUp(() async => temporary = await Directory.systemTemp.createTemp("updater-orchestrator-"));
  tearDown(() async => temporary.delete(recursive: true));

  test(
    "workspace preparation finishes before cloning; clone events are forwarded unchanged",
    () async {
      final paths = PathsService(Directory("${temporary.path}/workspace"));
      final releaseClone = Completer<void>();
      const progress = ProgressChanged(operation: .downloadingSource, value: .5);
      final source = _ControlledSource(paths.checkout, (tag) async* {
        expect(tag, "v1");
        expect(await paths.out.exists(), isTrue);
        await releaseClone.future;
        yield progress;
        yield const BuildOutput("diagnostic");
      });
      final events = <BuildEvent>[];
      final done = OrchestratorService(paths, source).run(tag: "v1").forEach(events.add);
      while (!events.any((event) => event is PhaseChanged && event.phase == .cloning)) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(
        events.first,
        isA<PhaseChanged>().having((event) => event.phase, "phase", BuildPhase.preparing),
      );
      expect(events.whereType<ProgressChanged>(), isEmpty);
      releaseClone.complete();
      await done;
      expect(events[2], same(progress));
      expect(events[3], isA<BuildOutput>());
      expect(events.last, isA<BuildCompleted>());
    },
  );

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
}

class _ControlledSource extends SourceService {
  final Stream<BuildEvent> Function(String) events;

  new(super.checkout, this.events);

  @override
  Stream<BuildEvent> clone({required String tag}) => events(tag);
}
