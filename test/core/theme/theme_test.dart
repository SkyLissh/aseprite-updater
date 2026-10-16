import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:nes_ui/nes_ui.dart";

import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/core/theme/palette.dart";
import "package:aseprite_updater/core/theme/spacing.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("the palette keeps NES UI's existing dark colors", () {
    final before = flutterNesTheme(brightness: .dark);
    final after = updaterTheme();

    List<Color> colors(ThemeData theme) {
      final button = theme.extension<NesButtonTheme>()!;
      final icon = theme.extension<NesIconTheme>()!;
      final snackbar = theme.extension<NesSnackbarTheme>()!;
      final progress = theme.extension<NesProgressBarTheme>()!;
      final tooltip = theme.extension<NesTooltipTheme>()!;
      final container = theme.extension<NesContainerTheme>()!;
      final bottomSheet = theme.extension<NesBottomSheetTheme>()!;
      final link = theme.extension<NesLinkTheme>()!;

      return [
        button.normal,
        button.primary,
        button.success,
        button.warning,
        button.error,
        button.lightLabelColor,
        button.darkLabelColor,
        button.lightIconTheme.primary,
        button.lightIconTheme.secondary,
        button.lightIconTheme.accent,
        button.lightIconTheme.shadow,
        button.darkIconTheme.primary,
        button.darkIconTheme.secondary,
        button.darkIconTheme.accent,
        button.darkIconTheme.shadow,
        icon.primary,
        icon.secondary,
        icon.accent,
        icon.shadow,
        theme.extension<NesOverlayTransitionTheme>()!.color,
        snackbar.normal,
        snackbar.success,
        snackbar.warning,
        snackbar.error,
        progress.background,
        progress.color,
        tooltip.background,
        tooltip.textColor,
        container.backgroundColor,
        container.borderColor,
        bottomSheet.backgroundColor,
        bottomSheet.borderColor,
        link.linkColor,
        link.disabledColor,
        theme.inputDecorationTheme.border!.borderSide.color,
        theme.inputDecorationTheme.enabledBorder!.borderSide.color,
        theme.inputDecorationTheme.focusedBorder!.borderSide.color,
        theme.inputDecorationTheme.errorBorder!.borderSide.color,
        theme.inputDecorationTheme.focusedErrorBorder!.borderSide.color,
      ];
    }

    expect(after.colorScheme, before.colorScheme);
    expect(after.textTheme, before.textTheme);
    expect(after.extensions.containsKey(Palette), isTrue);
    expect(after.extensions.containsKey(Spacing), isTrue);
    expect(after.palette.error, after.extension<NesButtonTheme>()!.error);
    expect(after.spacing.lg, 16);
    expect(after.extension<NesButtonTheme>()!.borderColor, before.textTheme.labelMedium!.color);
    expect(colors(after), colors(before));
  });
}
