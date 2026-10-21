import "package:flutter/material.dart";

import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/core/extensions/extensions.dart";
import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/features/build/providers/providers.dart";
import "package:aseprite_updater/features/build/models/models.dart";

import "build_operation_progress.dart";

class BuildProgress extends ConsumerWidget {
  final BuildStatus status;

  const new({required this.status, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final heading = ref.watch(
      buildControllerProvider.select(
        (state) => switch (state.step) {
          Preparing() => l10n.build_preparing_workspace,
          Cloning() => l10n.build_getting_source,
          DownloadingSkia() => l10n.build_downloading_skia,
          Configuring() => l10n.build_configuring,
          Compiling() => l10n.build_compiling,
          Deploying() => l10n.build_deploying,
        },
      ),
    );

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
              .running => heading,
            },
            style: theme.textTheme.titleLarge,
            textAlign: .center,
          ),
          if (status == .running) ...[const SizedBox(height: 42), const BuildOperationProgress()],
        ],
      ),
    );
  }
}
