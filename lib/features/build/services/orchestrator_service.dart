import "package:aseprite_updater/features/build/models/models.dart";

import "paths_service.dart";
import "source_service.dart";

class OrchestratorService(final PathsService paths, final SourceService source) {
  Stream<BuildEvent> run({required String tag}) async* {
    yield const StepChanged(BuildStep.preparing());
    await paths.ensureDirectoriesExist();

    yield const StepChanged(BuildStep.cloning(operation: .connectingSource));

    await for (final progress in source.clone(tag: tag)) {
      yield StepChanged(
        BuildStep.cloning(operation: progress.operation, progress: progress.progress),
      );
    }

    yield const StepChanged(BuildStep.deploying());

    yield const BuildCompleted();
  }
}
