import "package:aseprite_updater/features/build/models/models.dart";

import "paths_service.dart";
import "source_service.dart";
import "skia_service.dart";

class OrchestratorService(
  final PathsService paths,
  final SourceService source,
  final SkiaService skia,
) {
  Stream<BuildEvent> run({required String tag}) async* {
    yield const StepChanged(.preparing());
    await paths.ensureDirectoriesExist();

    yield const StepChanged(.cloning());
    await source.clone(tag: tag);

    yield const StepChanged(.downloadingSkia(receivedBytes: 0));
    await for (final progress in skia.download()) {
      yield StepChanged(
        .downloadingSkia(receivedBytes: progress.receivedBytes, totalBytes: progress.totalBytes),
      );
    }

    yield const StepChanged(.deploying());
    yield const BuildCompleted();
  }
}
