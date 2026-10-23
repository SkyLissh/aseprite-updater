import "dart:async";

import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/core/theme/palette.dart";
import "package:aseprite_updater/core/theme/spacing.dart";
import "package:aseprite_updater/features/build/build.dart";
import "package:aseprite_updater/l10n/app_localizations.dart";

import "support/controlled_orchestrator.dart";

void main() {
  late ControlledOrchestrator orchestrator;
  late ProviderContainer container;

  setUp(() {
    orchestrator = ControlledOrchestrator();
    container = ProviderContainer(
      overrides: [orchestratorProvider.overrideWithValue(orchestrator)],
    );
  });
  tearDown(() => container.dispose());

  Future<void> showProgress(WidgetTester tester, {double width = 400}) => tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: flutterNesTheme(customExtensions: [Palette(), const Spacing()]),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              child: Consumer(
                builder: (context, ref, _) => BuildProgress(
                  status: ref.watch(buildControllerProvider.select((state) => state.status)),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets("workspace preparation and cloning use only animated pixels", (tester) async {
    unawaited(container.read(buildControllerProvider.notifier).run(tag: "v1"));
    await showProgress(tester);
    expect(find.text("Preparing your workspace…"), findsOneWidget);
    expect(find.byType(NesPixelRowLoadingIndicator), findsOneWidget);
    expect(find.byType(NesProgressBar), findsNothing);
    orchestrator.add(const StepChanged(BuildStep.cloning()));
    await tester.pump();
    expect(find.text("Getting source code…"), findsOneWidget);
    expect(find.byType(NesProgressBar), findsNothing);
    expect(find.byType(NesPixelRowLoadingIndicator), findsOneWidget);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets("measured download progress uses a bounded bar; equal snapshots do not rebuild it", (
    tester,
  ) async {
    unawaited(container.read(buildControllerProvider.notifier).run(tag: "v1"));
    orchestrator.add(
      const StepChanged(BuildStep.downloadingSkia(receivedBytes: 42, totalBytes: 100)),
    );
    await showProgress(tester, width: 180);
    await tester.pump();
    final bar = tester.widget<NesProgressBar>(find.byType(NesProgressBar));
    expect(bar.value, .42);
    expect(find.text("Downloading Skia…"), findsOneWidget);
    expect(find.byType(NesPixelRowLoadingIndicator), findsNothing);
    expect(tester.getSize(find.byType(NesProgressBar)).width, lessThanOrEqualTo(180));
    for (var i = 0; i < 1000; i++) {
      orchestrator.add(
        StepChanged(
          BuildStep.downloadingSkia(receivedBytes: (bar.value * 100).round(), totalBytes: 100),
        ),
      );
    }
    await tester.pump();
    expect(identical(tester.widget(find.byType(NesProgressBar)), bar), isTrue);
    expect(tester.takeException(), isNull);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("measurement updates preserve the heading and progress subtree", (tester) async {
    unawaited(container.read(buildControllerProvider.notifier).run(tag: "v1"));
    orchestrator.add(
      const StepChanged(BuildStep.downloadingSkia(receivedBytes: 10, totalBytes: 100)),
    );
    await showProgress(tester);
    await tester.pump();
    final heading = tester.widget<Text>(find.text("Downloading Skia…"));
    final progressElement = tester.element(find.byType(BuildOperationProgress));

    orchestrator.add(
      const StepChanged(BuildStep.downloadingSkia(receivedBytes: 60, totalBytes: 100)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<NesProgressBar>(find.byType(NesProgressBar)).value, .6);
    expect(tester.widget<Text>(find.text("Downloading Skia…")), same(heading));
    expect(tester.element(find.byType(BuildOperationProgress)), same(progressElement));
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  testWidgets("compilation changes from unknown progress to a measured bar", (tester) async {
    unawaited(container.read(buildControllerProvider.notifier).run(tag: "v1"));
    orchestrator.add(const StepChanged(BuildStep.compiling(completedTasks: 0)));
    await showProgress(tester);
    await tester.pump();
    expect(find.byType(NesPixelRowLoadingIndicator), findsOneWidget);
    expect(find.byType(NesProgressBar), findsNothing);

    orchestrator.add(const StepChanged(BuildStep.compiling(completedTasks: 2, totalTasks: 8)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<NesProgressBar>(find.byType(NesProgressBar)).value, .25);
    expect(find.byType(NesPixelRowLoadingIndicator), findsNothing);
    expect(find.text("Building Aseprite…"), findsOneWidget);
    expect(find.textContaining("2/8"), findsNothing);

    orchestrator.add(const StepChanged(BuildStep.compiling(completedTasks: 6, totalTasks: 8)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<NesProgressBar>(find.byType(NesProgressBar)).value, .75);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  for (final (step, heading, fraction) in <(BuildStep, String, double?)>[
    (const BuildStep.cloning(), "Getting source code…", null),
    (const BuildStep.downloadingSkia(receivedBytes: 25, totalBytes: 100), "Downloading Skia…", .25),
    (const BuildStep.downloadingSkia(receivedBytes: 25), "Downloading Skia…", null),
    (const BuildStep.extractingSkia(completedFiles: 1, totalFiles: 4), "Extracting Skia…", .25),
    (const BuildStep.extractingSkia(completedFiles: 0), "Extracting Skia…", null),
    (const BuildStep.configuring(), "Preparing the build…", null),
    (const BuildStep.compiling(completedTasks: 3, totalTasks: 4), "Building Aseprite…", .75),
    (const BuildStep.compiling(completedTasks: 3), "Building Aseprite…", null),
    (const BuildStep.deploying(), "Installing the build…", null),
  ]) {
    testWidgets("$step renders its heading and measured or unknown progress", (tester) async {
      unawaited(container.read(buildControllerProvider.notifier).run(tag: "v1"));
      orchestrator.add(StepChanged(step));
      await showProgress(tester);
      await tester.pump();
      expect(find.text(heading), findsOneWidget);
      if (fraction == null) {
        expect(find.byType(NesProgressBar), findsNothing);
        expect(find.byType(NesPixelRowLoadingIndicator), findsOneWidget);
      } else {
        expect(tester.widget<NesProgressBar>(find.byType(NesProgressBar)).value, fraction);
        expect(find.byType(NesPixelRowLoadingIndicator), findsNothing);
      }
      orchestrator.add(const BuildCompleted());
      await tester.pump();
    });
  }

  for (final status in [BuildStatus.idle, BuildStatus.completed, BuildStatus.failed]) {
    testWidgets("$status shows a terminal label and no animation or stale operation", (
      tester,
    ) async {
      if (status != BuildStatus.idle) {
        unawaited(container.read(buildControllerProvider.notifier).run(tag: "v1"));
        orchestrator.add(const StepChanged(BuildStep.cloning()));
        await showProgress(tester);
        if (status == BuildStatus.failed) {
          orchestrator.streams.last.addError(StateError("clone failed"));
        } else {
          orchestrator.add(const BuildCompleted());
        }
        await tester.pump();
      } else {
        await showProgress(tester);
      }
      expect(
        find.text(switch (status) {
          .idle => "Ready to build",
          .completed => "Build completed",
          .failed => "Build failed",
          .running => throw StateError("Unexpected running state"),
        }),
        findsOneWidget,
      );
      expect(find.byType(NesPixelRowLoadingIndicator), findsNothing);
      expect(find.byType(NesProgressBar), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.transientCallbackCount, 0);
    });
  }
}
