import "package:aseprite_updater/core/providers/providers.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:aseprite_updater/features/release/release.dart";

part "release_service.g.dart";

@Riverpod(keepAlive: true)
ReleaseService releaseService(Ref ref) {
  final paths = ref.watch(pathsProvider);

  return ReleaseService(installation: paths.installation);
}
