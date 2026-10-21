import "package:nes_ui/nes_ui.dart";

import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/features/release/providers/providers.dart";
import "package:aseprite_updater/features/release/widgets/widgets.dart";

import "support/controlled_repo.dart";
import "support/release_fixture.dart";
import "support/release_test_app.dart";

void main() {
  late ControlledRepo repo;
  late ProviderContainer container;
  late List<String> updates;

  setUp(() {
    repo = ControlledRepo();
    updates = [];
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [repoProvider.overrideWithValue(repo)],
    );
  });
  tearDown(() => container.dispose());

  Future<void> showOverview(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: releaseTestApp(ReleaseOverview(onUpdate: updates.add)),
      ),
    );
    await tester.pump();

    expect(repo.calls, 1);
  }

  testWidgets("pending release shows a loader without actions", (tester) async {
    await showOverview(tester);

    expect(find.byType(NesHourglassLoadingIndicator), findsOneWidget);
    expect(find.text("Update"), findsNothing);
    expect(find.text("Changelog"), findsNothing);
    expect(updates, isEmpty);
  });

  testWidgets("loaded release shows its tag and Update passes the exact tag", (tester) async {
    repo.result.complete(releaseFixture());
    await showOverview(tester);

    expect(find.text("Aseprite v1.3.0"), findsOneWidget);
    expect(find.byType(NesHourglassLoadingIndicator), findsNothing);
    await tester.tap(find.text("Update"));
    await tester.pump();

    expect(updates, ["v1.3.0"]);
  });

  testWidgets("changelog opens the release modal with the matching Markdown", (tester) async {
    repo.result.complete(releaseFixture());
    await showOverview(tester);
    await tester.tap(find.text("Changelog"));
    await tester.pumpAndSettle();

    expect(find.byType(ReleaseModal), findsOneWidget);
    expect(find.text("v1.3.0"), findsOneWidget);
    expect(find.text("Highlights", findRichText: true), findsOneWidget);
    expect(find.text("Improved brushes.", findRichText: true), findsOneWidget);
    expect(updates, isEmpty);
  });

  testWidgets("failed release shows localized error without update actions", (tester) async {
    await showOverview(tester);
    repo.result.completeError(StateError("offline"));
    await tester.pump();
    await tester.pump();

    expect(find.text("Something went wrong"), findsOneWidget);
    expect(find.text("Update"), findsNothing);
    expect(find.byType(NesHourglassLoadingIndicator), findsNothing);
    expect(updates, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
