import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/providers/providers.dart";

import "support/controlled_orchestrator.dart";

void main() {
  late ControlledOrchestrator orchestrator;
  late ProviderContainer container;
  late BuildController controller;
  late List<BuildState> states;

  setUp(() {
    orchestrator = ControlledOrchestrator();
    container = ProviderContainer(
      overrides: [orchestratorProvider.overrideWithValue(orchestrator)],
    );
    controller = container.read(buildControllerProvider.notifier);
    states = [];
    container.listen(buildControllerProvider, (_, next) => states.add(next));
  });
  tearDown(() => container.dispose());

  BuildState current() => container.read(buildControllerProvider);

  testWidgets("duplicates and diagnostics do not publish; latest value coalesces at 100ms", (
    tester,
  ) async {
    unawaited(controller.run(tag: "v1"));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .1));
    await tester.pump();
    final count = states.length;
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .1));
    for (var i = 0; i < 10000; i++) {
      orchestrator.add(BuildOutput("diagnostic $i"));
    }
    await tester.pump();
    expect(states, hasLength(count));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .2));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .3));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 39));
    expect(current().progress, .1);
    await tester.pump(const Duration(milliseconds: 1));
    expect(current().progress, .3);
    expect(states, hasLength(count + 1));
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("latest value returning to the published value suppresses an update", (tester) async {
    unawaited(controller.run(tag: "v1"));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .1));
    await tester.pump();
    final count = states.length;
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .2));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(states, hasLength(count));
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("operation and phase transitions are immediate and cancel stale timers", (
    tester,
  ) async {
    unawaited(controller.run(tag: "v1"));
    orchestrator.add(const PhaseChanged(.cloning));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .1));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .8));
    await tester.pump();
    orchestrator.add(const ProgressChanged(operation: .resolvingSource, value: .2));
    await tester.pump();
    expect(current().operation, BuildOperation.resolvingSource);
    expect(current().progress, .2);
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().progress, .2);
    orchestrator.add(const ProgressChanged(operation: .resolvingSource, value: .9));
    orchestrator.add(const PhaseChanged(.deploying));
    await tester.pump();
    expect(current().operation, isNull);
    expect(current().progress, isNull);
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().progress, isNull);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("100 percent does not complete; terminal events cancel pending updates", (
    tester,
  ) async {
    final run = controller.run(tag: "v1");
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: 1));
    await tester.pump();
    expect(current().status, BuildStatus.running);
    orchestrator.add(const ProgressChanged(operation: .resolvingSource, value: .1));
    orchestrator.add(const ProgressChanged(operation: .resolvingSource, value: .9));
    orchestrator.add(const BuildCompleted());
    await tester.pump();
    expect(current().status, BuildStatus.completed);
    await tester.runAsync(() => run);
    expect(current().status, BuildStatus.completed);
    expect(current().operation, isNull);
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().progress, isNull);
  });

  testWidgets("exceptions are retained without escaping; restarting resets all run fields", (
    tester,
  ) async {
    final run = controller.run(tag: "v1");
    await controller.run(tag: "ignored");
    expect(orchestrator.tags, ["v1"]);
    orchestrator.add(const PhaseChanged(.cloning));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: 1));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .5));
    orchestrator.streams.last.addError(StateError("clone failed"));
    await tester.pump();
    await tester.runAsync(() => expectLater(run, completes));
    expect(current().status, BuildStatus.failed);
    expect(current().errorMessage, contains("clone failed"));
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().progress, isNull);
    final restart = controller.run(tag: "v2");
    expect(current(), const BuildState(status: .running));
    expect(orchestrator.tags, ["v1", "v2"]);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
    await tester.runAsync(() => restart);
    expect(current().status, BuildStatus.completed);
  });

  testWidgets("an unexpected stream end fails even without output", (tester) async {
    final run = controller.run(tag: "v1");
    unawaited(orchestrator.streams.last.close());
    await tester.pump();
    await tester.runAsync(() => run);
    expect(current().status, BuildStatus.failed);
    expect(current().errorMessage, contains("without completing"));
  });

  testWidgets("a completed run can restart; indeterminate updates coalesce too", (tester) async {
    final first = controller.run(tag: "v1");
    orchestrator.add(const BuildCompleted());
    await tester.pump();
    await tester.runAsync(() => first);
    unawaited(controller.run(tag: "v2"));
    expect(current(), const BuildState(status: .running));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .1));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource));
    await tester.pump();
    expect(current().progress, .1);
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().progress, isNull);
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .6));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().progress, .6);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("disposal cancels scheduled updates and ignores late events", (tester) async {
    final run = controller.run(tag: "v1");
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .1));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .9));
    await tester.pump();
    final count = states.length;
    container.dispose();
    orchestrator.add(const PhaseChanged(.deploying));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() => run);
    expect(states, hasLength(count));
  });
}
