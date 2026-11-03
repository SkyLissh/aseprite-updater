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

  test("maps release assets into typed names and download URLs", () {
    final release = Release.fromJson({
      ...releaseJson(),
      "assets": [
        {
          "name": "Skia-Linux-Release-x64.zip",
          "browser_download_url": "https://example.invalid/skia.zip",
        },
      ],
    });

    expect(release.assets, [
      const ReleaseAsset(
        name: "Skia-Linux-Release-x64.zip",
        browserDownloadUrl: "https://example.invalid/skia.zip",
      ),
    ]);
    expect(Release.fromJson(release.toJson()), release);
  });

  test("defaults to no assets for existing release responses and constructors", () {
    expect(Release.fromJson(releaseJson()).assets, isEmpty);
    expect(
      Release(
        tagName: "v1",
        name: "Aseprite",
        body: "",
        publishedAt: DateTime.utc(2025),
        draft: false,
        prerelease: false,
      ).assets,
      isEmpty,
    );
  });

  test("rejects assets missing a name or download URL", () {
    for (final field in ["name", "browser_download_url"]) {
      final asset = {"name": "skia.zip", "browser_download_url": "https://example.invalid/skia.zip"}
        ..remove(field);

      expect(
        () => Release.fromJson({
          ...releaseJson(),
          "assets": [asset],
        }),
        throwsA(isA<TypeError>()),
        reason: field,
      );
    }
  });
}
