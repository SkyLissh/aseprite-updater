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
                  phase: ref.watch(buildControllerProvider.select((state) => state.phase)),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  testWidgets("workspace preparation and unknown clone progress use animated pixels", (
    tester,
  ) async {
    unawaited(container.read(buildControllerProvider.notifier).run(tag: "v1"));
    await showProgress(tester);
    expect(find.text("Preparing your workspace…"), findsOneWidget);
    expect(find.byType(NesPixelRowLoadingIndicator), findsOneWidget);
    expect(find.byType(NesProgressBar), findsNothing);
    orchestrator.add(const PhaseChanged(.cloning));
    orchestrator.add(const ProgressChanged(operation: .downloadingSubmodules));
    await tester.pump();
    expect(find.text("Downloading source components…"), findsOneWidget);
    expect(find.byType(NesPixelRowLoadingIndicator), findsOneWidget);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets("measured clone progress uses a bounded bar; diagnostics do not rebuild it", (
    tester,
  ) async {
    unawaited(container.read(buildControllerProvider.notifier).run(tag: "v1"));
    orchestrator.add(const PhaseChanged(.cloning));
    orchestrator.add(const ProgressChanged(operation: .downloadingSource, value: .42));
    await showProgress(tester, width: 180);
    await tester.pump();
    final bar = tester.widget<NesProgressBar>(find.byType(NesProgressBar));
    expect(bar.value, .42);
    expect(find.text("Downloading source…"), findsOneWidget);
    expect(find.byType(NesPixelRowLoadingIndicator), findsNothing);
    expect(tester.getSize(find.byType(NesProgressBar)).width, lessThanOrEqualTo(180));
    for (var i = 0; i < 1000; i++) {
      orchestrator.add(BuildOutput("diagnostic $i"));
    }
    await tester.pump();
    expect(identical(tester.widget(find.byType(NesProgressBar)), bar), isTrue);
    expect(tester.takeException(), isNull);
    orchestrator.add(const BuildCompleted());
    await tester.pump();
  });

  for (final status in [BuildStatus.idle, BuildStatus.completed, BuildStatus.failed]) {
    testWidgets("$status shows a terminal label and no animation or stale operation", (
      tester,
    ) async {
      if (status != BuildStatus.idle) {
        unawaited(container.read(buildControllerProvider.notifier).run(tag: "v1"));
        orchestrator.add(const PhaseChanged(.cloning));
        orchestrator.add(const ProgressChanged(operation: .downloadingSubmodules));
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
      expect(find.text("Downloading source components…"), findsNothing);
      expect(find.byType(NesPixelRowLoadingIndicator), findsNothing);
      expect(find.byType(NesProgressBar), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      expect(tester.binding.transientCallbackCount, 0);
    });
  }
}
