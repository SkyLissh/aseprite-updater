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
  void step(BuildStep value) => orchestrator.add(StepChanged(value));
  void downloadProgress(int receivedBytes, {int? totalBytes = 100}) =>
      step(BuildStep.downloadingSkia(receivedBytes: receivedBytes, totalBytes: totalBytes));

  testWidgets("equal snapshots do not publish; latest value coalesces at 100ms", (tester) async {
    unawaited(controller.run(tag: "v1"));
    downloadProgress(10);
    await tester.pump();
    final count = states.length;
    downloadProgress(10);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(states, hasLength(count));

    downloadProgress(20);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    downloadProgress(30);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 39));
    expect(current().step.fraction, .1);
    await tester.pump(const Duration(milliseconds: 1));
    expect(current().step.fraction, .3);
    expect(states, hasLength(count + 1));
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("latest snapshot returning to the published value suppresses an update", (
    tester,
  ) async {
    unawaited(controller.run(tag: "v1"));
    downloadProgress(10);
    await tester.pump();
    final count = states.length;
    downloadProgress(20);
    downloadProgress(10);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(states, hasLength(count));
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("step transitions are immediate and cancel stale snapshots", (tester) async {
    unawaited(controller.run(tag: "v1"));
    downloadProgress(10);
    downloadProgress(80);
    await tester.pump();
    step(const BuildStep.cloning());
    await tester.pump();
    expect(current().step, const BuildStep.cloning());
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().step.fraction, isNull);

    step(const BuildStep.cloning());
    step(const BuildStep.downloadingSkia(receivedBytes: 10, totalBytes: 100));
    await tester.pump();
    expect(current().step, const BuildStep.downloadingSkia(receivedBytes: 10, totalBytes: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().step.fraction, .1);

    step(const BuildStep.deploying());
    await tester.pump();
    expect(current().step, const BuildStep.deploying());
    expect(current().step.fraction, isNull);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("download and compilation coalesce complete snapshots including raw counts", (
    tester,
  ) async {
    unawaited(controller.run(tag: "v1"));
    step(const BuildStep.downloadingSkia(receivedBytes: 10, totalBytes: 100));
    step(const BuildStep.downloadingSkia(receivedBytes: 20, totalBytes: 200));
    await tester.pump();
    expect(current().step, const BuildStep.downloadingSkia(receivedBytes: 10, totalBytes: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().step, const BuildStep.downloadingSkia(receivedBytes: 20, totalBytes: 200));

    step(const BuildStep.compiling(completedTasks: 1, totalTasks: 10));
    step(const BuildStep.compiling(completedTasks: 4, totalTasks: 20));
    await tester.pump();
    expect(current().step, const BuildStep.compiling(completedTasks: 1, totalTasks: 10));
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().step, const BuildStep.compiling(completedTasks: 4, totalTasks: 20));
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("100 percent does not complete; completion retains the last published step", (
    tester,
  ) async {
    final run = controller.run(tag: "v1");
    downloadProgress(100);
    await tester.pump();
    expect(current().status, BuildStatus.running);
    step(const BuildStep.compiling(completedTasks: 1, totalTasks: 10));
    step(const BuildStep.compiling(completedTasks: 9, totalTasks: 10));
    orchestrator.add(const BuildCompleted());
    await tester.pump();
    await tester.runAsync(() => run);
    expect(current().status, BuildStatus.completed);
    expect(current().step, const BuildStep.compiling(completedTasks: 1, totalTasks: 10));
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().step.fraction, .1);
  });

  testWidgets("failures cancel pending updates; restarting resets the step and error", (
    tester,
  ) async {
    final run = controller.run(tag: "v1");
    await controller.run(tag: "ignored");
    expect(orchestrator.tags, ["v1"]);
    downloadProgress(100);
    downloadProgress(50);
    orchestrator.streams.last.addError(StateError("clone failed"));
    await tester.pump();
    await tester.runAsync(() => expectLater(run, completes));
    expect(current().status, BuildStatus.failed);
    expect(current().errorMessage, contains("clone failed"));
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().step.fraction, 1);

    final restart = controller.run(tag: "v2");
    expect(current(), const BuildState(status: .running));
    expect(current().step, const BuildStep.preparing());
    expect(orchestrator.tags, ["v1", "v2"]);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
    await tester.runAsync(() => restart);
    expect(current().status, BuildStatus.completed);
  });

  testWidgets("an unexpected stream end fails without completing", (tester) async {
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
    downloadProgress(10);
    downloadProgress(10, totalBytes: null);
    await tester.pump();
    expect(current().step.fraction, .1);
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().step.fraction, isNull);
    downloadProgress(60);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(current().step.fraction, .6);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("disposal cancels scheduled updates and ignores late events", (tester) async {
    final run = controller.run(tag: "v1");
    downloadProgress(10);
    downloadProgress(90);
    await tester.pump();
    final count = states.length;
    container.dispose();
    step(const BuildStep.deploying());
    await tester.pump(const Duration(milliseconds: 100));
    await tester.runAsync(() => run);
    expect(states, hasLength(count));
  });
}
