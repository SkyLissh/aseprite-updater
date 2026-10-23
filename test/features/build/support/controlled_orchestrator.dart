import "dart:async";
import "dart:io";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/services.dart";

class ControlledOrchestrator extends OrchestratorService {
  final streams = <StreamController<BuildEvent>>[];
  final tags = <String>[];

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
      );

  @override
  Stream<BuildEvent> run({required String tag}) {
    tags.add(tag);
    final stream = StreamController<BuildEvent>();
    streams.add(stream);
    return stream.stream;
  }

  void add(BuildEvent event) => streams.last.add(event);
}
