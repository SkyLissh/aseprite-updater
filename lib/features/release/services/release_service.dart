import "dart:io";

import "package:dio/dio.dart";
import "package:path/path.dart" as p;

import "package:aseprite_updater/features/release/models/models.dart";

enum ReleaseType { stable, beta }

class ReleaseService({required final Directory installation, Dio? client}) {
  final Dio _api =
      client ??
      Dio(
        BaseOptions(
          baseUrl: "https://api.github.com/repos/aseprite/aseprite",
          headers: {"Accept": "application/vnd.github+json"},
        ),
      );

  Future<Release> getLatestRelease({ReleaseType type = .stable}) async {
    final res = await _api.get("/releases/latest");

    final release = Release.fromJson(res.data);

    if (release.tagName.contains("beta") && type == .stable) {
      throw Exception("Latest release is a beta release");
    }

    return release;
  }

  Future<String?> installedRelease() async {
    final release = File(p.join(installation.path, "release"));

    if (!await release.exists()) return null;

    return (await release.readAsString()).trim();
  }
}
