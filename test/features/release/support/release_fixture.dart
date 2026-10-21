import "package:aseprite_updater/features/release/models/models.dart";

Map<String, dynamic> releaseJson() => {
  "tag_name": "v1.3.0",
  "name": "Aseprite 1.3.0",
  "body": "# Highlights\n\nImproved brushes.",
  "published_at": "2025-01-02T03:04:05Z",
  "draft": false,
  "prerelease": false,
};

Release releaseFixture() => Release.fromJson(releaseJson());
