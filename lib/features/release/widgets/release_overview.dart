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
    final releases = ref.watch(releasesProvider);

    final spacing = Theme.of(context).spacing;
    final l10n = context.l10n;

    return switch (releases) {
      AsyncData(:final value) when value.current != null => Column(
        spacing: spacing.lg,
        mainAxisAlignment: .center,
        children: [
          NesIcon(iconData: NesIcons.download, size: const .square(64)),
          Text("${l10n.aseprite} ${value.current}"),
          Row(
            spacing: spacing.lg,
            mainAxisAlignment: .center,
            children: [
              NesButton.text(
                type: .normal,
                text: l10n.changelog,
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      ReleaseModal(tagName: value.latest.tagName, body: value.latest.body),
                ),
              ),
              NesButton.text(
                type: .primary,
                text: l10n.update,
                onPressed: () => onUpdate(value.latest.tagName),
              ),
            ],
          ),
        ],
      ),
      AsyncData(:final value) => Column(
        mainAxisAlignment: .center,
        spacing: spacing.lg,
        children: [
          NesIcon(iconData: NesIcons.moon, size: const .square(64)),
          Text(l10n.build_start_message),
          SizedBox(height: spacing.lg),
          NesButton.text(
            type: .primary,
            text: l10n.build_start,
            onPressed: () => onUpdate(value.latest.tagName),
          ),
        ],
      ),
      AsyncLoading() => const Center(child: NesHourglassLoadingIndicator()),
      AsyncError() => Center(child: Text(l10n.something_went_wrong)),
    };
  }
}
