import "package:aseprite_updater/core/theme/theme.dart";
import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:aseprite_updater/features/build/providers/providers.dart";

class BuildProgress extends StatelessWidget {
  final BuildState state;

  const new({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Column(
      mainAxisAlignment: .center,
      children: [
        Text(switch (state.phase) {
          .preparing => "Preparing build...",
          .cloning => "Getting source code...",
          .downloadingSkia => "Downloading Skia...",
          .configuring => "Configuring build...",
          .compiling => "Compiling Aseprite...",
          .deploying => "Deploying build...",
        }, style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: theme.spacing.lg),
        if (state.status == .running) ...[
          NesJumpingIconsLoadingIndicator(icons: [NesIcons.heart, NesIcons.energy, NesIcons.moon]),
          SizedBox(height: theme.spacing.md),
          NesContainer(
            label: "Building",
            width: size.width * 0.4 + 80,
            height: 240,
            child: NesSingleChildScrollView(
              child: Padding(
                padding: .all(theme.spacing.md),
                child: Text(state.output.join("\n"), style: theme.textTheme.bodyMedium),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
