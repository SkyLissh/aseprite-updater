import "package:aseprite_updater/core/services/paths_service.dart";
import "package:aseprite_updater/features/build/models/models.dart";

import "compilation_service.dart";
import "deployment_service.dart";
import "source_service.dart";
import "skia_service.dart";

class OrchestratorService(
  final PathsService paths,
  final SourceService source,
  final SkiaService skia,
  final CompilationService compilation,
  final DeploymentService deployment,
) {
  Stream<BuildEvent> run({required String tag, required BuildOperation operation}) async* {
    yield const StepChanged(.preparing());
    await paths.ensureDirectoriesExist();

    yield const StepChanged(.cloning());
    switch (operation) {
      case BuildOperation.install:
        await source.clone(tag: tag);
      case BuildOperation.update:
        await source.update(tag: tag);
    }

    final skiaTag = await source.requiredSkia();
    final installedSkiaTag = await skia.installedTag();

    if (skiaTag != installedSkiaTag) {
      yield const StepChanged(.downloadingSkia(receivedBytes: 0));
      await for (final progress in skia.download(releaseTag: skiaTag)) {
        yield StepChanged(
          .downloadingSkia(receivedBytes: progress.receivedBytes, totalBytes: progress.totalBytes),
        );
      }

      yield const StepChanged(.extractingSkia(completedFiles: 0));
      await for (final progress in skia.extract(releaseTag: skiaTag)) {
        yield StepChanged(
          .extractingSkia(completedFiles: progress.completedFiles, totalFiles: progress.totalFiles),
        );
      }
    }

    yield const StepChanged(.configuring());
    await compilation.configure();

    yield const StepChanged(.compiling(completedTasks: 0));
    await for (final progress in compilation.compile()) {
      yield StepChanged(
        .compiling(completedTasks: progress.completedTasks, totalTasks: progress.totalTasks),
      );
    }

    yield const StepChanged(.deploying());
    await deployment.deploy(tag: tag);

    yield const BuildCompleted();
  }
}
