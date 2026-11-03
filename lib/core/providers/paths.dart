import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:aseprite_updater/core/services/paths_service.dart";

part "paths.g.dart";

@Riverpod(keepAlive: true)
PathsService paths(Ref ref) => PathsService.linux();
