import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:aseprite_updater/core/providers/providers.dart";
import "package:aseprite_updater/features/build/services/services.dart";

part "orchestrator.g.dart";

@Riverpod(keepAlive: true)
OrchestratorService orchestrator(Ref ref) {
  final paths = ref.watch(pathsProvider);
  return OrchestratorService(
    paths,
    SourceService(paths.checkout),
    SkiaService(paths.skia),
    CompilationService(checkout: paths.checkout, build: paths.build, skia: paths.skia),
    DeploymentService(
      build: paths.build,
      checkout: paths.checkout,
      installation: paths.installation,
      desktopEntry: paths.desktopEntry,
      icon: paths.icon,
      commandLink: paths.commandLink,
    ),
  );
}
