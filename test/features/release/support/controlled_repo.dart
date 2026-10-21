import "dart:async";

import "package:aseprite_updater/features/release/models/models.dart";
import "package:aseprite_updater/features/release/services/services.dart";

class ControlledRepo extends RepoService {
  // Create the future in the caller's test zone, including widget tests.
  late final result = Completer<Release>();
  int calls = 0;

  @override
  Future<Release> getLatestRelease() {
    calls++;

    return result.future;
  }
}
