import "package:freezed_annotation/freezed_annotation.dart";

part "build_step.freezed.dart";

@freezed
sealed class BuildStep with _$BuildStep {
  const new _();

  const factory preparing() = Preparing;
  const factory cloning() = Cloning;
  const factory downloadingSkia({required int receivedBytes, int? totalBytes}) = DownloadingSkia;
  const factory extractingSkia({required int completedFiles, int? totalFiles}) = ExtractingSkia;
  const factory configuring() = Configuring;
  const factory compiling({required int completedTasks, int? totalTasks}) = Compiling;
  const factory deploying() = Deploying;

  double? get fraction {
    final value = switch (this) {
      DownloadingSkia(:final receivedBytes, :final totalBytes)
          when totalBytes != null && totalBytes > 0 =>
        receivedBytes / totalBytes,
      ExtractingSkia(:final completedFiles, :final totalFiles)
          when totalFiles != null && totalFiles > 0 =>
        completedFiles / totalFiles,
      Compiling(:final completedTasks, :final totalTasks)
          when totalTasks != null && totalTasks > 0 =>
        completedTasks / totalTasks,
      _ => null,
    };

    return value?.clamp(0, 1).toDouble();
  }
}
