import "package:aseprite_updater/features/releases/models/release.dart";
import "package:dio/dio.dart";

class RepoService {
  final Dio _api = Dio(
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
