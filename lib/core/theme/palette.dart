import "package:flutter/material.dart";

/// Colors used by the dark NES UI theme and the app's own widgets.
final class Palette extends ThemeExtension<Palette> {
  final Color primarySeed;
  final Color normal;
  final Color primary;
  final Color success;
  final Color warning;
  final Color error;
  final Color lightLabel;
  final Color darkLabel;
  final Color iconAccent;
  final Color iconShadow;
  final Color darkIconPrimary;
  final Color darkIconSecondary;
  final Color overlay;

  Palette({
    this.primarySeed = const Color(0xffb4b6f6),
    this.normal = const Color(0xffffffff),
    this.primary = const Color(0xff209cee),
    this.success = const Color(0xff92cc41),
    this.warning = const Color(0xfff7d51d),
    this.error = const Color(0xffe76e55),
    this.lightLabel = const Color(0xffffffff),
    this.darkLabel = const Color(0xff000000),
    this.iconAccent = const Color(0xff9badb7),
    this.iconShadow = const Color(0xff696a6a),
    this.darkIconPrimary = const Color(0xff808080),
    this.darkIconSecondary = const Color(0xffe5e5e5),
    this.overlay = const Color(0xff8c8c8c),
  });

  // Match the colors NES UI derives from Flutter's dark seeded theme.
  late final ThemeData _materialTheme = ThemeData(brightness: .dark, colorSchemeSeed: primarySeed);

  Color get foreground => _materialTheme.textTheme.bodyMedium?.color ?? darkLabel;
  Color get label => _materialTheme.textTheme.labelMedium?.color ?? darkLabel;
  Color get surface => _materialTheme.colorScheme.surface;
  Color get card => _materialTheme.cardColor;
  Color get schemePrimary => _materialTheme.colorScheme.primary;
  Color get schemeError => _materialTheme.colorScheme.error;
  Color get disabledLink => foreground.withValues(alpha: 0.4);

  @override
  Palette copyWith({
    Color? primarySeed,
    Color? normal,
    Color? primary,
    Color? success,
    Color? warning,
    Color? error,
    Color? lightLabel,
    Color? darkLabel,
    Color? iconAccent,
    Color? iconShadow,
    Color? darkIconPrimary,
    Color? darkIconSecondary,
    Color? overlay,
  }) => Palette(
    primarySeed: primarySeed ?? this.primarySeed,
    normal: normal ?? this.normal,
    primary: primary ?? this.primary,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    lightLabel: lightLabel ?? this.lightLabel,
    darkLabel: darkLabel ?? this.darkLabel,
    iconAccent: iconAccent ?? this.iconAccent,
    iconShadow: iconShadow ?? this.iconShadow,
    darkIconPrimary: darkIconPrimary ?? this.darkIconPrimary,
    darkIconSecondary: darkIconSecondary ?? this.darkIconSecondary,
    overlay: overlay ?? this.overlay,
  );

  @override
  Palette lerp(covariant Palette? other, double t) {
    if (other == null) return this;
    return Palette(
      primarySeed: Color.lerp(primarySeed, other.primarySeed, t)!,
      normal: Color.lerp(normal, other.normal, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      lightLabel: Color.lerp(lightLabel, other.lightLabel, t)!,
      darkLabel: Color.lerp(darkLabel, other.darkLabel, t)!,
      iconAccent: Color.lerp(iconAccent, other.iconAccent, t)!,
      iconShadow: Color.lerp(iconShadow, other.iconShadow, t)!,
      darkIconPrimary: Color.lerp(darkIconPrimary, other.darkIconPrimary, t)!,
      darkIconSecondary: Color.lerp(darkIconSecondary, other.darkIconSecondary, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
    );
  }
}
