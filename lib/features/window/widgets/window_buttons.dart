import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";
import "package:aseprite_updater/core/theme/theme.dart";

class WindowButtons extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onMinimize;
  final VoidCallback onMaximize;

  const new({required this.onClose, required this.onMaximize, required this.onMinimize, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: .symmetric(horizontal: theme.spacing.sm),
      child: Row(
        spacing: theme.spacing.md,
        children: [
          NesIconButton(
            icon: NesIcons.remove,
            onPress: onMinimize,
            size: const .square(16),
            primaryColor: theme.palette.darkIconSecondary,
          ),
          NesIconButton(
            icon: NesIcons.add,
            onPress: onMaximize,
            size: const .square(16),
            primaryColor: theme.palette.darkIconSecondary,
          ),
          NesIconButton(
            icon: NesIcons.close,
            onPress: onClose,
            size: const .square(16),
            primaryColor: theme.palette.darkIconSecondary,
          ),
        ],
      ),
    );
  }
}
