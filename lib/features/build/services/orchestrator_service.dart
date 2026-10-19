import "package:aseprite_updater/features/build/models/models.dart";

import "paths_service.dart";
import "source_service.dart";

class OrchestratorService {
  final PathsService paths;
  final SourceService source;

  new(this.paths, this.source);

  Stream<BuildEvent> run({required String tag}) async* {
    yield const PhaseChanged(.preparing);
    await paths.ensureDirectoriesExist();

    yield const PhaseChanged(.cloning);
    yield* source.clone(tag: tag);

    yield const PhaseChanged(.deploying);

    yield const BuildCompleted();
  }
}
