import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:aseprite_updater/core/theme/palette.dart";
import "package:aseprite_updater/core/theme/spacing.dart";

Widget windowTestApp(Widget child) => MaterialApp(
  theme: flutterNesTheme(customExtensions: [Palette(), const Spacing()]),
  home: Scaffold(body: Center(child: child)),
);
