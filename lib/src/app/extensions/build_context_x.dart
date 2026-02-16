import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/layout/app_breakpoints.dart';
import 'package:memuno_app/src/app/theme/app_spacing.dart';

/// Convenience extensions for common theme lookups.
extension BuildContextX on BuildContext {
  /// Theme-based spacing scale.
  AppSpacing get spacing =>
      Theme.of(this).extension<AppSpacing>() ?? const AppSpacing();

  /// Current media size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Current screen width.
  double get screenWidth => screenSize.width;

  /// Current screen height.
  double get screenHeight => screenSize.height;

  /// Current orientation.
  Orientation get orientation => MediaQuery.orientationOf(this);

  /// Current layout size bucket.
  AppLayoutSize get layoutSize => AppBreakpoints.resolve(screenWidth);

  bool get isCompact => layoutSize == AppLayoutSize.compact;
  bool get isMedium => layoutSize == AppLayoutSize.medium;
  bool get isLarge => layoutSize == AppLayoutSize.large;
  bool get isExtraLarge => layoutSize == AppLayoutSize.extraLarge;
}
