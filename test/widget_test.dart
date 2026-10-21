import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:window_manager/window_manager.dart";

import "package:aseprite_updater/core/screens/home.dart";
import "package:aseprite_updater/features/release/providers/providers.dart";
import "package:aseprite_updater/l10n/app_localizations.dart";
import "package:aseprite_updater/main.dart";

import "features/release/support/controlled_repo.dart";
import "features/release/support/release_fixture.dart";
import "features/release/support/release_test_app.dart";
import "features/window/support/window_manager_fake.dart";

void main() {
  testWidgets("AsepriteUpdater opens Home and renders the localized release", (tester) async {
    final native = WindowManagerFake()..install();
    final repo = ControlledRepo();
    final listenersBefore = windowManager.listeners.length;
    addTearDown(native.uninstall);

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [repoProvider.overrideWithValue(repo)],
        child: AsepriteUpdater(theme: releaseTestTheme()),
      ),
    );
    await tester.pump();

    expect(find.byType(Home), findsOneWidget);
    expect(find.byType(Scaffold), findsNWidgets(2));
    expect(windowManager.listeners.length, listenersBefore + 1);
    expect(find.byType(NesHourglassLoadingIndicator), findsOneWidget);
    expect(repo.calls, 1);

    repo.result.complete(releaseFixture());
    await tester.pump();
    await tester.pump();

    expect(find.text("Aseprite v1.3.0"), findsOneWidget);
    expect(find.text("Update"), findsOneWidget);
    expect(find.text("Changelog"), findsOneWidget);
    final context = tester.element(find.byType(Home));
    expect(AppLocalizations.of(context)!.app_title, "Aseprite Updater");
    expect(Localizations.localeOf(context), const Locale("en"));
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).routerConfig, isNotNull);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(windowManager.listeners.length, listenersBefore);
  });
}
