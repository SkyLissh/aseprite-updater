import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:nes_ui/nes_ui.dart";

import "package:aseprite_updater/core/theme/palette.dart";
import "package:aseprite_updater/core/theme/spacing.dart";

extension ThemeTokens on ThemeData {
  Palette get palette => extension<Palette>()!;
  Spacing get spacing => extension<Spacing>()!;
}

ThemeData updaterTheme() {
  final palette = Palette();
  const spacing = Spacing();
  final materialTheme = ThemeData(brightness: .dark, colorSchemeSeed: palette.primarySeed);
  final textTheme = GoogleFonts.pressStart2pTextTheme(materialTheme.textTheme);

  return flutterNesTheme(
    brightness: .dark,
    // The explicit defaults keep Palette as the source for NES UI colors.
    // ignore: avoid_redundant_argument_values
    primaryColor: palette.primarySeed,
    textTheme: textTheme,
    nesButtonTheme: NesButtonTheme(
      normal: palette.normal,
      primary: palette.primary,
      success: palette.success,
      warning: palette.warning,
      error: palette.error,
      lightLabelColor: palette.lightLabel,
      darkLabelColor: palette.darkLabel,
      borderColor: palette.label,
      lightIconTheme: NesIconTheme(
        primary: palette.normal,
        secondary: palette.darkLabel,
        accent: palette.iconAccent,
        shadow: palette.iconShadow,
      ),
      darkIconTheme: NesIconTheme(
        primary: palette.darkLabel,
        secondary: palette.normal,
        accent: palette.iconShadow,
        shadow: palette.iconAccent,
      ),
    ),
    nesIconTheme: NesIconTheme(
      primary: palette.darkIconPrimary,
      secondary: palette.darkIconSecondary,
      accent: palette.iconShadow,
      shadow: palette.iconAccent,
    ),
    nesOverlayTransitionTheme: NesOverlayTransitionTheme(color: palette.overlay),
    nesSnackbarTheme: NesSnackbarTheme(
      normal: palette.normal,
      success: palette.success,
      warning: palette.warning,
      error: palette.error,
    ),
    nesProgressBarTheme: NesProgressBarTheme(
      background: palette.foreground,
      color: palette.schemePrimary,
    ),
    nesTooltipTheme: NesTooltipTheme(background: palette.foreground, textColor: palette.surface),
    nesContainerTheme: NesContainerTheme(
      backgroundColor: palette.card,
      borderColor: palette.label,
      labelTextStyle: textTheme.labelMedium ?? const TextStyle(),
    ),
    nesBottomSheetTheme: NesBottomSheetTheme(
      backgroundColor: palette.card,
      borderColor: palette.label,
    ),
    nesLinkTheme: NesLinkTheme(linkColor: palette.primary, disabledColor: palette.disabledLink),
    nesInputDecorationTheme: NesInputDecorationTheme(
      borderColor: palette.foreground,
      enabledBorderColor: palette.foreground,
      focusedBorderColor: palette.schemePrimary,
      errorBorderColor: palette.schemeError,
      focusedErrorBorderColor: palette.schemeError,
    ),
    customExtensions: [palette, spacing],
  );
}
