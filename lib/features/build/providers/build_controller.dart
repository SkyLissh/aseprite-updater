import "package:riverpod_annotation/riverpod_annotation.dart";
import "package:freezed_annotation/freezed_annotation.dart";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/services.dart";

part "build_controller.freezed.dart";
part "build_controller.g.dart";

enum BuildStatus { idle, running, completed, failed }

@freezed
abstract class BuildState with _$BuildState {
  const factory({
    @Default(BuildPhase.preparing) BuildPhase phase,
    @Default(BuildStatus.idle) BuildStatus status,
    @Default([]) List<String> output,
  }) = _BuildState;
}

@Riverpod(keepAlive: true)
class BuildController extends _$BuildController {
  late final OrchestratorService _orchestrator;

  @override
  BuildState build() {
    final paths = PathsService.linux();
    final source = SourceService(paths.checkout);

    _orchestrator = OrchestratorService(paths, source);

    return const BuildState();
  }

  Future<void> run({required String tag}) async {
    if (state.status == BuildStatus.running) return;

    state = state.copyWith(phase: .preparing, status: .running, output: []);

    try {
      await for (final event in _orchestrator.run(tag: tag)) {
        if (!ref.mounted) return;

        state = switch (event) {
          final PhaseChanged phaseChanged => state.copyWith(phase: phaseChanged.phase),
          final BuildOutput buildOutput => state.copyWith(
            output: [...state.output, buildOutput.line],
          ),
          BuildCompleted _ => state.copyWith(status: .completed),
        };
      }
    } catch (error) {
      if (ref.mounted) {
        state = state.copyWith(status: .failed);
      }
      rethrow;
    }
  }
}
