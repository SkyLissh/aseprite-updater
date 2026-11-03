import "dart:io";

import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/core/extensions/extensions.dart";
import "package:aseprite_updater/core/functions/functions.dart";
import "package:aseprite_updater/core/logger.dart";
import "package:aseprite_updater/core/providers/providers.dart";
import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/features/build/providers/providers.dart";
import "package:aseprite_updater/features/build/models/models.dart";

import "build_operation_progress.dart";

class BuildProgress extends ConsumerWidget {
  final BuildStatus status;
  final VoidCallback onBack;
  final Future<void> Function(Directory) launcher;

  const new({
    required this.status,
    required this.onBack,
    this.launcher = launchAseprite,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);

    final heading = ref.watch(
      buildControllerProvider.select(
        (state) => switch (state.step) {
          Preparing() => l10n.build_preparing_workspace,
          Cloning() => l10n.build_getting_source,
          DownloadingSkia() => l10n.build_downloading_skia,
          ExtractingSkia() => l10n.build_extracting_skia,
          Configuring() => l10n.build_configuring,
          Compiling() => l10n.build_compiling,
          Deploying() => l10n.build_deploying,
        },
      ),
    );

    Future<void> launch() async {
      try {
        final installation = ref.read(pathsProvider).installation;

        await launcher(installation);
      } catch (error, stackTrace) {
        loggger.e("Failed to launch Aseprite", error: error, stackTrace: stackTrace);

        if (!context.mounted) return;

        NesSnackbar.show(context, text: l10n.aseprite_launch_failed, type: .error);
      }
    }

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
          if (status == .completed) ...[
            SizedBox(height: theme.spacing.md),
            SizedBox(
              width: size.width * 0.6,
              child: Text(
                l10n.build_completed_sidenote,
                style: theme.textTheme.bodySmall,
                softWrap: true,
                textAlign: .center,
              ),
            ),
            const SizedBox(height: 42),
            SizedBox(
              width: size.width * 0.4,
              child: Row(
                spacing: theme.spacing.md,
                mainAxisAlignment: .center,
                children: [
                  Expanded(
                    child: NesButton(
                      type: .normal,
                      onPressed: onBack,
                      child: Text(l10n.back, textAlign: .center),
                    ),
                  ),
                  Expanded(
                    child: NesButton(
                      type: .primary,
                      onPressed: launch,
                      child: Text(l10n.open, textAlign: .center),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
