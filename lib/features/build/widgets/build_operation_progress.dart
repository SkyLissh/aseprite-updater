import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/features/build/providers/providers.dart";

class BuildOperationProgress extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(buildControllerProvider.select((state) => state.step.fraction));

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: switch (progress) {
        final value? => NesProgressBar(value: value),
        null => const NesPixelRowLoadingIndicator(),
      },
    );
  }
}
