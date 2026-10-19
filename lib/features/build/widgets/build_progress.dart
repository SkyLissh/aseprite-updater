import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/features/build/widgets/build_logs.dart";
import "package:aseprite_updater/features/build/providers/providers.dart";
import "package:aseprite_updater/features/build/models/models.dart";

class BuildProgress extends HookWidget {
  final BuildStatus status;
  final BuildPhase phase;

  const new({required this.status, required this.phase, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: .center,
      children: [
        Text(switch (phase) {
          .preparing => "Preparing build...",
          .cloning => "Getting source code...",
          .downloadingSkia => "Downloading Skia...",
          .configuring => "Configuring build...",
          .compiling => "Compiling Aseprite...",
          .deploying => "Deploying build...",
        }, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: theme.spacing.lg),
        if (status == .running) ...[
          NesJumpingIconsLoadingIndicator(icons: [NesIcons.heart, NesIcons.energy, NesIcons.moon]),
          SizedBox(height: theme.spacing.md),
          Consumer(
            builder: (context, ref, _) {
              final output = ref.watch(buildControllerProvider.select((state) => state.output));

              return BuildLogs(status: status, output: output);
            },
          ),
        ],
      ],
    );
  }
}
