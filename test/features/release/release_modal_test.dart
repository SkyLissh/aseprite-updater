import "package:flutter/services.dart";

import "package:flutter_markdown_plus/flutter_markdown_plus.dart";
import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/release/widgets/widgets.dart";

import "support/release_fixture.dart";
import "support/release_test_app.dart";

void main() {
  const channel = MethodChannel("plugins.flutter.io/url_launcher");
  late List<MethodCall> launches;

  setUp(() {
    launches = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async {
        launches.add(call);

        return true;
      },
    );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
  });

  testWidgets("renders tag and Markdown headings and content", (tester) async {
    final release = releaseFixture();
    await tester.pumpWidget(
      releaseTestApp(ReleaseModal(tagName: release.tagName, body: release.body)),
    );
    await tester.pump();

    expect(find.text("Aseprite"), findsOneWidget);
    expect(find.text("v1.3.0"), findsOneWidget);
    expect(find.text("Highlights", findRichText: true), findsOneWidget);
    expect(find.text("Improved brushes.", findRichText: true), findsOneWidget);
    expect(launches, isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final scheme in ["http", "https"]) {
    testWidgets("tapping a $scheme link requests an external launch", (tester) async {
      final url = "$scheme://example.com/release";
      await tester.pumpWidget(
        releaseTestApp(ReleaseModal(tagName: "v1.3.0", body: "[Website]($url)")),
      );
      await tester.pump();
      await tester.tap(find.text("Website", findRichText: true));
      await tester.pump();

      expect(launches, hasLength(1));
      expect(launches.single.method, "launch");
      expect(launches.single.arguments["url"], url);
      expect(launches.single.arguments["useWebView"], isFalse);
      expect(launches.single.arguments["useSafariVC"], isFalse);
    });
  }

  testWidgets("ignores missing, relative, malformed and unsupported link targets", (tester) async {
    await tester.pumpWidget(
      releaseTestApp(const ReleaseModal(tagName: "v1.3.0", body: "Release notes")),
    );
    await tester.pump();
    final markdown = tester.widget<MarkdownBody>(find.byType(MarkdownBody));

    for (final href in [
      null,
      "",
      "/relative",
      "http://[",
      "mailto:user@example.com",
      "javascript:alert(1)",
    ]) {
      markdown.onTapLink!("Link", href, "");
    }
    await tester.pump();

    expect(launches, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
