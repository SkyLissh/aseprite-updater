import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:aseprite_updater/core/extensions/extensions.dart";
import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/features/build/providers/providers.dart";
import "package:aseprite_updater/features/build/models/models.dart";

import "build_operation_progress.dart";

class BuildProgress extends StatelessWidget {
  final BuildStatus status;
  final BuildPhase phase;

  const new({required this.status, required this.phase, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Padding(
      padding: .all(theme.spacing.lg),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Text(
            switch (status) {
              .idle => l10n.build_idle,
              .completed => l10n.build_completed,
              .failed => l10n.build_failed,
              .running => switch (phase) {
                .preparing => l10n.build_preparing_workspace,
                .cloning => l10n.build_getting_source,
                .downloadingSkia => l10n.build_downloading_skia,
                .configuring => l10n.build_configuring,
                .compiling => l10n.build_compiling,
                .deploying => l10n.build_deploying,
              },
            },
            style: theme.textTheme.titleLarge,
            textAlign: .center,
          ),
          if (status == .running) ...[
            SizedBox(height: theme.spacing.lg),
            if (phase == .cloning)
              const BuildOperationProgress()
            else
              const NesPixelRowLoadingIndicator(),
          ],
        ],
      ),
    );
  }
}
