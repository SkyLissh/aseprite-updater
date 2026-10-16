import "package:riverpod_annotation/riverpod_annotation.dart";

import "package:aseprite_updater/features/releases/services/services.dart";

part "repo.g.dart";

@Riverpod(keepAlive: true)
RepoService repo(Ref ref) {
  return RepoService();
}
