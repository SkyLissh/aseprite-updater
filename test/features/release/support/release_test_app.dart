import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:aseprite_updater/core/theme/palette.dart";
import "package:aseprite_updater/core/theme/spacing.dart";
import "package:aseprite_updater/l10n/app_localizations.dart";

ThemeData releaseTestTheme() => flutterNesTheme(customExtensions: [Palette(), const Spacing()]);

Widget releaseTestApp(Widget child) => MaterialApp(
  theme: releaseTestTheme(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);
