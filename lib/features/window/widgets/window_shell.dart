import "package:flutter/material.dart";
import "package:flutter_hooks/flutter_hooks.dart";

import "package:aseprite_updater/features/window/hooks/hooks.dart";
import "package:aseprite_updater/core/theme/theme.dart";
import "package:nes_ui/nes_ui.dart";

class WindowShell extends HookWidget {
  final Widget child;

  const new({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final window = useWindow();

    if (window.isMaximized) return child;

    final theme = Theme.of(context);
    return NesContainer(
      padding: EdgeInsets.all(theme.spacing.sm),
      borderColor: theme.palette.darkIconPrimary,
      child: child,
    );
  }
}
