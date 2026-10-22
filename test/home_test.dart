import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:window_manager/window_manager.dart";

import "package:aseprite_updater/core/screens/home.dart";
import "package:aseprite_updater/features/build/build.dart";
import "package:aseprite_updater/features/release/providers/providers.dart";

import "features/build/support/controlled_orchestrator.dart";
import "features/release/support/release_fixture.dart";
import "features/release/support/release_test_app.dart";
import "features/window/support/window_manager_fake.dart";

void main() {
  for (final fails in [false, true]) {
    testWidgets(
      "Update starts the selected release and shows ${fails ? 'failure' : 'completion'}",
      (tester) async {
        final native = WindowManagerFake()..install();
        final listenersBefore = windowManager.listeners.length;
        final orchestrator = ControlledOrchestrator();
        final container = ProviderContainer(
          retry: (_, _) => null,
          overrides: [
            latestReleaseProvider.overrideWith((ref) => releaseFixture()),
            orchestratorProvider.overrideWithValue(orchestrator),
          ],
        );
        addTearDown(native.uninstall);
        addTearDown(container.dispose);
        await tester.pumpWidget(
          UncontrolledProviderScope(container: container, child: releaseTestApp(const Home())),
        );
        await tester.pump();
        expect(find.text("Aseprite v1.3.0"), findsOneWidget);
        expect(windowManager.listeners.length, listenersBefore + 1);

        await tester.tap(find.text("Update"));
        await tester.pump();
        expect(orchestrator.tags, ["v1.3.0"]);
        expect(find.text("Preparing your workspace…"), findsOneWidget);
        expect(find.text("Update"), findsNothing);

        orchestrator.add(const StepChanged(BuildStep.cloning()));
        await tester.pump();
        expect(find.byType(NesProgressBar), findsNothing);
        expect(find.byType(NesPixelRowLoadingIndicator), findsOneWidget);
        expect(find.text("Getting source code…"), findsOneWidget);
        expect(container.read(buildControllerProvider).status, BuildStatus.running);

        final progressElement = tester.element(find.byType(BuildProgress));
        for (final event in ["maximize", "unmaximize"]) {
          native.emit(event);
          await tester.pump();

          expect(tester.element(find.byType(BuildProgress)), same(progressElement));
          expect(orchestrator.tags, ["v1.3.0"]);
          expect(windowManager.listeners.length, listenersBefore + 1);
        }

        if (fails) {
          orchestrator.streams.last.addError(StateError("clone failed"));
        } else {
          orchestrator.add(const BuildCompleted());
        }
        await tester.pump();
        expect(
          container.read(buildControllerProvider).status,
          fails ? BuildStatus.failed : BuildStatus.completed,
        );
        await tester.pump();
        expect(find.text(fails ? "Build failed" : "Build completed"), findsOneWidget);
        expect(find.byType(NesProgressBar), findsNothing);
        expect(find.byType(NesPixelRowLoadingIndicator), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        expect(windowManager.listeners.length, listenersBefore);
      },
    );
  }
}
