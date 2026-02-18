import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/layout/app_breakpoints.dart';
import 'package:memuno_app/src/app/theme/app_spacing.dart';

/// Convenience extensions for common theme lookups.
extension BuildContextX on BuildContext {
  /// Theme-based spacing scale.
  AppSpacing get spacing =>
      Theme.of(this).extension<AppSpacing>() ?? const AppSpacing();

  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenHeight => screenSize.height;
  double get screenWidth => screenSize.width;

  EdgeInsets get padding => MediaQuery.paddingOf(this);
  double get topPadding => padding.top;
  double get leftPadding => padding.left;
  double get rightPadding => padding.right;
  double get bottomPadding => padding.bottom;

  /// Current orientation.
  Orientation get orientation => MediaQuery.orientationOf(this);

  /// Current layout size bucket.
  AppLayoutSize get layoutSize => AppBreakpoints.resolve(screenWidth);

  bool get isCompact => layoutSize == AppLayoutSize.compact;
  bool get isMedium => layoutSize == AppLayoutSize.medium;
  bool get isLarge => layoutSize == AppLayoutSize.large;
  bool get isExtraLarge => layoutSize == AppLayoutSize.extraLarge;
}

class DeviceInsets {
  final double top;
  final double right;
  final double bottom;
  final double left;

  const DeviceInsets({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  EdgeInsets toEdgeInsets() => EdgeInsets.fromLTRB(left, top, right, bottom);
}
