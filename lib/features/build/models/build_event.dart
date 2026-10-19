import "build_phase.dart";
import "build_operation.dart";

sealed class BuildEvent {
  const new();
}

class PhaseChanged extends BuildEvent {
  final BuildPhase phase;

  const new(this.phase);
}

class BuildOutput extends BuildEvent {
  final String line;

  const new(this.line);
}

class ProgressChanged extends BuildEvent {
  final BuildOperation operation;
  final double? value;

  const new({required this.operation, this.value});
}

class BuildCompleted extends BuildEvent {
  const new();
}
