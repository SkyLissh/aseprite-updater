import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/build/models/models.dart";

void main() {
  test("steps derive bounded fractions from their own measurements", () {
    for (final (step, expected) in <(BuildStep, double?)>[
      (const BuildStep.preparing(), null),
      (const BuildStep.configuring(), null),
      (const BuildStep.deploying(), null),
      (const BuildStep.cloning(operation: .connectingSource), null),
      (const BuildStep.cloning(operation: .downloadingSource, progress: .42), .42),
      (const BuildStep.cloning(operation: .downloadingSource, progress: -1), 0),
      (const BuildStep.cloning(operation: .downloadingSource, progress: 2), 1),
      (const BuildStep.downloadingSkia(receivedBytes: 25, totalBytes: 100), .25),
      (const BuildStep.downloadingSkia(receivedBytes: 0, totalBytes: 100), 0),
      (const BuildStep.downloadingSkia(receivedBytes: 200, totalBytes: 100), 1),
      (const BuildStep.downloadingSkia(receivedBytes: 25), null),
      (const BuildStep.downloadingSkia(receivedBytes: 25, totalBytes: 0), null),
      (const BuildStep.downloadingSkia(receivedBytes: 25, totalBytes: -1), null),
      (const BuildStep.compiling(completedTasks: 3, totalTasks: 4), .75),
      (const BuildStep.compiling(completedTasks: 4, totalTasks: 4), 1),
      (const BuildStep.compiling(completedTasks: 0, totalTasks: 4), 0),
      (const BuildStep.compiling(completedTasks: 5, totalTasks: 4), 1),
      (const BuildStep.compiling(completedTasks: 3), null),
      (const BuildStep.compiling(completedTasks: 3, totalTasks: 0), null),
      (const BuildStep.compiling(completedTasks: 3, totalTasks: -1), null),
    ]) {
      expect(step.fraction, expected, reason: "$step");
    }
  });
}
