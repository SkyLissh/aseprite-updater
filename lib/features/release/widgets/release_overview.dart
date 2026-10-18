import "package:flutter/material.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";
import "package:nes_ui/nes_ui.dart";

import "package:aseprite_updater/core/extensions/extensions.dart";
import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/features/release/providers/providers.dart";

import "release_modal.dart";

class ReleaseOverview extends ConsumerWidget {
  final ValueChanged<String> onUpdate;

  const new({required this.onUpdate, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final release = ref.watch(latestReleaseProvider);

    final spacing = Theme.of(context).spacing;
    final l10n = context.l10n;

    return switch (release) {
      AsyncData(:final value) => Column(
        mainAxisAlignment: .center,
        children: [
          NesIcon(iconData: NesIcons.download, size: const Size.square(64)),
          SizedBox(height: spacing.lg),
          Text("${l10n.aseprite} ${value.tagName}"),
          SizedBox(height: spacing.lg),
          Row(
            mainAxisAlignment: .center,
            children: [
              NesButton.text(
                type: .normal,
                text: l10n.changelog,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ReleaseModal(tagName: value.tagName, body: value.body),
                ),
              ),
              SizedBox(width: spacing.lg),
              NesButton.text(
                type: .primary,
                text: l10n.update,
                onPressed: () => onUpdate(value.tagName),
              ),
            ],
          ),
        ],
      ),
      AsyncLoading() => const Center(child: NesHourglassLoadingIndicator()),
      AsyncError() => Center(child: Text(l10n.something_went_wrong)),
    };
  }
}
