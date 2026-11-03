import "dart:async";
import "dart:io";

import "package:aseprite_updater/features/release/models/models.dart";
import "package:aseprite_updater/features/release/services/services.dart";

class ControlledRepo extends ReleaseService {
  ControlledRepo() : super(installation: Directory.systemTemp);

  // Create the future in the caller's test zone, including widget tests.
  late var result = Completer<Release>();
  int calls = 0;
  String? current = "v1.2.0";

  @override
  Future<Release> getLatestRelease({ReleaseType type = ReleaseType.stable}) {
    calls++;

    return result.future;
  }

  @override
  Future<String?> installedRelease() async => current;
}
