import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/core/extensions/extensions.dart";
import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/providers/providers.dart";

class BuildOperationProgress extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = ref.watch(buildControllerProvider.select((state) => state.step));

    final theme = Theme.of(context);
    final l10n = context.l10n;

    final progress = step.fraction;
    final label = switch (step) {
      Cloning(:final operation) => switch (operation) {
        .connectingSource => l10n.build_connecting_source,
        .downloadingSource => l10n.build_downloading_source,
        .resolvingSource => l10n.build_resolving_source,
        .checkingOutSource => l10n.build_checking_out_source,
        .downloadingSubmodules => l10n.build_downloading_submodules,
      },
      _ => null,
    };

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Column(
        mainAxisSize: .min,
        children: [
          if (progress case final value?)
            NesProgressBar(value: value, label: label)
          else
            const NesPixelRowLoadingIndicator(),
          if (label != null) ...[
            SizedBox(height: theme.spacing.md),
            Text(label, style: theme.textTheme.bodyMedium, textAlign: .center),
          ],
        ],
      ),
    );
  }
}
