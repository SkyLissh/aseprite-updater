import "package:aseprite_updater/features/releases/models/release.dart";
import "package:aseprite_updater/features/releases/providers/providers.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";

part "release.g.dart";

@riverpod
FutureOr<Release> latestRelease(Ref ref) async {
  final service = ref.watch(repoProvider);

  return await service.getLatestRelease();
}
