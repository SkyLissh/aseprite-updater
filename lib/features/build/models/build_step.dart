import "package:freezed_annotation/freezed_annotation.dart";

import "git_operation.dart";

part "build_step.freezed.dart";

@freezed
sealed class BuildStep with _$BuildStep {
  const new _();

  const factory preparing() = Preparing;
  const factory cloning({required GitOperation operation, double? progress}) = Cloning;
  const factory downloadingSkia({required int receivedBytes, int? totalBytes}) = DownloadingSkia;
  const factory configuring() = Configuring;
  const factory compiling({required int completedTasks, int? totalTasks}) = Compiling;
  const factory deploying() = Deploying;

  double? get fraction {
    final value = switch (this) {
      Cloning(:final progress) => progress,
      DownloadingSkia(:final receivedBytes, :final totalBytes)
          when totalBytes != null && totalBytes > 0 =>
        receivedBytes / totalBytes,
      Compiling(:final completedTasks, :final totalTasks)
          when totalTasks != null && totalTasks > 0 =>
        completedTasks / totalTasks,
      _ => null,
    };

    return value?.clamp(0, 1).toDouble();
  }
}
