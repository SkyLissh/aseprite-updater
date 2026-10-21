import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:flutter_hooks/flutter_hooks.dart";
import "package:window_manager/window_manager.dart";

import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/features/window/hooks/hooks.dart";

import "window_buttons.dart";

class WindowShell extends HookWidget {
  final Widget child;

  const new({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final window = useWindow();

    final theme = Theme.of(context);

    return NesContainer(
      padding: window.isMaximized ? .zero : .all(theme.spacing.sm),
      borderColor: window.isMaximized ? Colors.transparent : theme.palette.darkIconPrimary,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kWindowCaptionHeight),
          child: Row(
            children: [
              const Expanded(
                child: DragToMoveArea(child: SizedBox(height: kWindowCaptionHeight)),
              ),
              WindowButtons(
                onMinimize: window.minimize,
                onMaximize: window.toggleMaximize,
                onClose: window.close,
              ),
            ],
          ),
        ),
        body: child,
      ),
    );
  }
}
