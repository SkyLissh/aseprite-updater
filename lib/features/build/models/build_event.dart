import "build_phase.dart";

sealed class BuildEvent {
  const BuildEvent();
}

class PhaseChanged extends BuildEvent {
  final BuildPhase phase;

  const PhaseChanged(this.phase);
}

class BuildOutput extends BuildEvent {
  final String output;

  const BuildOutput(this.output);
}

class BuildCompleted extends BuildEvent {
  const BuildCompleted();
}
