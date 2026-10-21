import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/release/models/models.dart";

import "support/release_fixture.dart";

void main() {
  test("maps GitHub fields, date, flags and Markdown without losing content", () {
    final release = Release.fromJson({...releaseJson(), "draft": true, "prerelease": true});

    expect(release.tagName, "v1.3.0");
    expect(release.name, "Aseprite 1.3.0");
    expect(release.body, "# Highlights\n\nImproved brushes.");
    expect(release.publishedAt, DateTime.utc(2025, 1, 2, 3, 4, 5));
    expect(release.draft, isTrue);
    expect(release.prerelease, isTrue);
  });

  test("rejects missing or incorrectly typed required API fields", () {
    for (final field in releaseJson().keys) {
      final json = releaseJson()..remove(field);

      expect(() => Release.fromJson(json), throwsA(isA<TypeError>()), reason: field);
    }
    expect(() => Release.fromJson({...releaseJson(), "tag_name": 13}), throwsA(isA<TypeError>()));
    expect(
      () => Release.fromJson({...releaseJson(), "published_at": "yesterday"}),
      throwsFormatException,
    );
  });
}
