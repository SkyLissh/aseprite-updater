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
    @Default(BuildStep.preparing()) BuildStep step,
    @Default(BuildStatus.idle) BuildStatus status,
    String? errorMessage,
  }) = _BuildState;
}

@Riverpod(keepAlive: true)
class BuildController extends _$BuildController {
  late OrchestratorService _orchestrator;
  Timer? _progressTimer;
  BuildStep? _pendingStep;

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
          case StepChanged(:final step):
            _queueStep(step);
          case BuildCompleted():
            _cancelProgress();
            state = state.copyWith(status: .completed);
            return;
        }
      }
      if (ref.mounted && state.status == .running) {
        throw StateError("Build event stream ended without completing");
      }
    } catch (error) {
      _cancelProgress();
      if (ref.mounted) {
        state = state.copyWith(status: .failed, errorMessage: error.toString());
      }
    }
  }

  void _queueStep(BuildStep step) {
    final isTransition = switch ((state.step, step)) {
      (Preparing(), Preparing()) ||
      (Cloning(), Cloning()) ||
      (DownloadingSkia(), DownloadingSkia()) ||
      (Configuring(), Configuring()) ||
      (Compiling(), Compiling()) ||
      (Deploying(), Deploying()) => false,
      _ => true,
    };

    if (isTransition) {
      _cancelProgress();

      state = state.copyWith(step: step);

      return;
    }

    if (step == state.step && _progressTimer == null) return;

    _pendingStep = step;

    _progressTimer ??= Timer(const Duration(milliseconds: 100), () {
      final pending = _pendingStep;

      _progressTimer = null;
      _pendingStep = null;

      if (ref.mounted && pending != null && pending != state.step) {
        state = state.copyWith(step: pending);
      }
    });
  }

  void _cancelProgress() {
    _progressTimer?.cancel();
    _progressTimer = null;
    _pendingStep = null;
  }
}
