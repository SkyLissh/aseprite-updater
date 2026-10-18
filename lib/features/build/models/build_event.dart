import "build_phase.dart";

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

class BuildCompleted extends BuildEvent {
  const new();
}
