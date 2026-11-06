import "package:flutter/material.dart";

class WindowDrag extends StatelessWidget {
  final VoidCallback onDrag;
  final VoidCallback onMaximize;
  final VoidCallback onSecondaryTap;
  final Widget? child;

  const WindowDrag({
    required this.onDrag,
    required this.onMaximize,
    required this.onSecondaryTap,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        behavior: .translucent,
        onPanStart: (_) => onDrag(),
        onDoubleTap: () => onMaximize(),
        onSecondaryTap: () => onSecondaryTap(),
        child: child,
      ),
    );
  }
}
