import "package:aseprite_updater/core/logger.dart";
import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:freezed_annotation/freezed_annotation.dart";

import "package:aseprite_updater/features/release/models/models.dart";

import "release_service.dart";

part "release.g.dart";
part "release.freezed.dart";

@freezed
abstract class ReleaseState with _$ReleaseState {
  const factory ReleaseState({required Release latest, String? current}) = _ReleaseState;
}

@riverpod
class Releases extends _$Releases {
  @override
  FutureOr<ReleaseState> build() async {
    final service = ref.watch(releaseServiceProvider);

    final latest = await service.getLatestRelease();
    final current = await service.installedRelease();

    logger.i("Latest release: ${latest.tagName}");
    logger.i("Current release: $current");

    return ReleaseState(latest: latest, current: current);
  }

  Future<void> searchUpdates() async {
    final service = ref.read(releaseServiceProvider);
    final latest = await service.getLatestRelease();

    if (!ref.mounted) return;
    if (latest.tagName == state.value?.latest.tagName) return;

    logger.i("Fetched latest release: $latest");
    await update((current) => current.copyWith(latest: latest));
  }
}
