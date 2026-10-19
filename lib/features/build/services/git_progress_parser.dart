import "package:aseprite_updater/features/build/models/models.dart";

class GitProgressParser {
  static final _percentage = RegExp(r"^\s*(\d+)%(?:\s|$)");
  bool _seenCloneHeader = false;
  bool _submodules = false;

  ProgressChanged? parse(String line, {required bool isStderr}) {
    if (!isStderr) return null;

    if (line.startsWith("Submodule '") && line.contains(" registered for path '")) {
      _submodules = true;

      return const ProgressChanged(operation: .downloadingSubmodules);
    }

    if (line.startsWith("Cloning into '")) {
      if (_seenCloneHeader) _submodules = true;

      _seenCloneHeader = true;

      return _submodules ? const ProgressChanged(operation: .downloadingSubmodules) : null;
    }

    final BuildOperation operation;
    final String progress;
    if (line.startsWith("Receiving objects:")) {
      operation = .downloadingSource;
      progress = line.substring("Receiving objects:".length);
    } else if (line.startsWith("Resolving deltas:")) {
      operation = .resolvingSource;
      progress = line.substring("Resolving deltas:".length);
    } else if (line.startsWith("Updating files:")) {
      operation = .checkingOutSource;
      progress = line.substring("Updating files:".length);
    } else if (line.startsWith("Checking out files:")) {
      operation = .checkingOutSource;
      progress = line.substring("Checking out files:".length);
    } else {
      return null;
    }

    if (_submodules) return const ProgressChanged(operation: .downloadingSubmodules);

    final match = _percentage.firstMatch(progress);
    final percentage = match == null ? null : int.tryParse(match.group(1)!);

    return ProgressChanged(
      operation: operation,
      value: percentage != null && percentage <= 100 ? percentage / 100 : null,
    );
  }
}
