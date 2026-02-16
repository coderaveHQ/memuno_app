import 'package:flutter/material.dart';

/// Spacing scale based on a 4pt grid.
@immutable
final class AppSpacing extends ThemeExtension<AppSpacing> {
  /// Creates an AppSpacing instance.
  const AppSpacing({this.baseUnit = 4.0})
    : xs = baseUnit * 1,
      sm = baseUnit * 2,
      md = baseUnit * 3,
      lg = baseUnit * 4,
      xl = baseUnit * 6,
      xxl = baseUnit * 8,
      xxxl = baseUnit * 12;

  /// Base unit used for spacing calculations.
  final double baseUnit;

  /// 4
  final double xs;

  /// 8
  final double sm;

  /// 12
  final double md;

  /// 16
  final double lg;

  /// 24
  final double xl;

  /// 32
  final double xxl;

  /// 48
  final double xxxl;

  @override
  /// Returns a copy with selectively overridden values.
  AppSpacing copyWith({double? baseUnit}) {
    return AppSpacing(baseUnit: baseUnit ?? this.baseUnit);
  }

  @override
  /// Linearly interpolates between two values.
  AppSpacing lerp(ThemeExtension<AppSpacing>? other, double t) {
    if (other is! AppSpacing) {
      return this;
    }
    return AppSpacing(baseUnit: _lerp(baseUnit, other.baseUnit, t));
  }
}

/// Linearly interpolates between two values.
double _lerp(double a, double b, double t) => a + (b - a) * t;
