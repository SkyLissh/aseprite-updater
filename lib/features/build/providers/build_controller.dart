import "dart:async";

import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:freezed_annotation/freezed_annotation.dart";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/services.dart";

import "orchestrator.dart";

part "build_controller.freezed.dart";
part "build_controller.g.dart";

enum BuildStatus { idle, running, completed, failed }

@freezed
abstract class BuildState with _$BuildState {
  const factory({
    @Default(BuildPhase.preparing) BuildPhase phase,
    @Default(BuildStatus.idle) BuildStatus status,
    BuildOperation? operation,
    double? progress,
    String? errorMessage,
  }) = _BuildState;
}

@Riverpod(keepAlive: true)
class BuildController extends _$BuildController {
  late OrchestratorService _orchestrator;
  Timer? _progressTimer;
  ProgressChanged? _pendingProgress;

  @override
  BuildState build() {
    _orchestrator = ref.read(orchestratorProvider);
    ref.onDispose(_cancelProgress);

    return const BuildState();
  }

  Future<void> run({required String tag}) async {
    if (state.status == BuildStatus.running) return;

    _cancelProgress();
    state = const BuildState(status: .running);

    try {
      await for (final event in _orchestrator.run(tag: tag)) {
        if (!ref.mounted) return;

        switch (event) {
          case PhaseChanged(:final phase):
            _cancelProgress();
            state = state.copyWith(phase: phase, operation: null, progress: null);
          case ProgressChanged():
            _queueProgress(event);
          case BuildOutput():
            break;
          case BuildCompleted():
            _cancelProgress();
            state = state.copyWith(status: .completed, operation: null, progress: null);
            return;
        }
      }
      if (ref.mounted && state.status == .running) {
        throw StateError("Build event stream ended without completing");
      }
    } catch (error) {
      _cancelProgress();
      if (ref.mounted) {
        state = state.copyWith(
          status: .failed,
          operation: null,
          progress: null,
          errorMessage: error.toString(),
        );
      }
    }
  }

  void _queueProgress(ProgressChanged event) {
    if (event.operation != state.operation) {
      _cancelProgress();

      state = state.copyWith(operation: event.operation, progress: event.value);

      return;
    }

    _pendingProgress = event;

    if (event.value == state.progress && _progressTimer == null) return;

    _progressTimer ??= Timer(const Duration(milliseconds: 100), () {
      final pending = _pendingProgress;

      _progressTimer = null;
      _pendingProgress = null;

      if (ref.mounted && pending != null && pending.value != state.progress) {
        state = state.copyWith(progress: pending.value);
      }
    });
  }

  void _cancelProgress() {
    _progressTimer?.cancel();
    _progressTimer = null;
    _pendingProgress = null;
  }
}
