import "build_step.dart";

sealed class const BuildEvent();

class const StepChanged(final BuildStep step) extends BuildEvent;

class const BuildCompleted() extends BuildEvent;
