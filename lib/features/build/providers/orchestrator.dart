import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:aseprite_updater/features/build/services/services.dart";

part "orchestrator.g.dart";

@Riverpod(keepAlive: true)
OrchestratorService orchestrator(Ref ref) {
  final paths = PathsService.linux();
  return OrchestratorService(
    paths,
    SourceService(paths.checkout),
    SkiaService(paths.skia, releaseTag: "m124-08a5439a6b", assetName: "Skia-Linux-Release-x64.zip"),
  );
}
