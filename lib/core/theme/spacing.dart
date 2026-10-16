import "package:flutter/material.dart";

final class Spacing extends ThemeExtension<Spacing> {
  final double xs;
  final double sm;
  final double md;
  final double lg;

  const Spacing({this.xs = 6, this.sm = 8, this.md = 12, this.lg = 16});

  @override
  Spacing copyWith({double? xs, double? sm, double? md, double? lg}) =>
      Spacing(xs: xs ?? this.xs, sm: sm ?? this.sm, md: md ?? this.md, lg: lg ?? this.lg);

  @override
  Spacing lerp(covariant Spacing? other, double t) {
    if (other == null) return this;
    return Spacing(
      xs: xs + (other.xs - xs) * t,
      sm: sm + (other.sm - sm) * t,
      md: md + (other.md - md) * t,
      lg: lg + (other.lg - lg) * t,
    );
  }
}
