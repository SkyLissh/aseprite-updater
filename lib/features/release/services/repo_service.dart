import "package:dio/dio.dart";

import "package:aseprite_updater/features/release/models/models.dart";

class RepoService({Dio? client}) {
  final Dio _api =
      client ??
      Dio(
        BaseOptions(
          baseUrl: "https://api.github.com/repos/aseprite/aseprite",
          headers: {"Accept": "application/vnd.github+json"},
        ),
      );

  Future<Release> getLatestRelease() async {
    final res = await _api.get("/releases/latest");

    return Release.fromJson(res.data);
  }
}
