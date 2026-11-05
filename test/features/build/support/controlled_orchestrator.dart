import "dart:async";
import "dart:io";

import "package:path/path.dart" as p;

import "package:aseprite_updater/core/services/paths_service.dart";
import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/services.dart";

class ControlledOrchestrator extends OrchestratorService {
  final streams = <StreamController<BuildEvent>>[];
  final tags = <String>[];
  final operations = <BuildOperation>[];

  new()
    : super(
        PathsService(Directory.systemTemp),
        SourceService(Directory.systemTemp),
        SkiaService(Directory.systemTemp, releaseTag: "test-skia", assetName: "skia.zip"),
        CompilationService(
          checkout: Directory.systemTemp,
          build: Directory.systemTemp,
          skia: Directory.systemTemp,
        ),
        DeploymentService(
          build: Directory.systemTemp,
          checkout: Directory.systemTemp,
          installation: Directory.systemTemp,
          desktopEntry: File(p.join(Directory.systemTemp.path, "aseprite.desktop")),
          icon: File(p.join(Directory.systemTemp.path, "aseprite.png")),
          commandLink: Link(p.join(Directory.systemTemp.path, "aseprite")),
        ),
      );

  @override
  Stream<BuildEvent> run({required String tag, required BuildOperation operation}) {
    tags.add(tag);
    operations.add(operation);
    final stream = StreamController<BuildEvent>();
    streams.add(stream);
    return stream.stream;
  }

  void add(BuildEvent event) => streams.last.add(event);
}
