import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/layout/app_breakpoints.dart';
import 'package:memuno_app/src/app/theme/app_spacing.dart';

/// Layout helpers for responsive pages.
final class AppLayout {
  /// Creates a AppLayout instance.
  const AppLayout._();

  /// Max width for auth/forms on medium+ screens.
  static const double formMaxWidth = 420;

  /// Max width for wide forms on desktop screens.
  static const double formMaxWidthWide = 480;

  /// Returns a max width for forms based on the screen size.
  static double formMaxWidthFor(double width) {
    final AppLayoutSize size = AppBreakpoints.resolve(width);
    return switch (size) {
      AppLayoutSize.compact => width,
      AppLayoutSize.medium => formMaxWidth,
      AppLayoutSize.large => formMaxWidth,
      AppLayoutSize.extraLarge => formMaxWidthWide,
    };
  }

  /// Returns page padding based on the spacing scale and layout size.
  static EdgeInsets pagePadding(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    final AppLayoutSize size = AppBreakpoints.resolve(screen.width);
    final AppSpacing spacing =
        Theme.of(context).extension<AppSpacing>() ?? const AppSpacing();

    final double horizontal = switch (size) {
      AppLayoutSize.compact => spacing.lg,
      AppLayoutSize.medium => spacing.xl,
      AppLayoutSize.large => spacing.xxl,
      AppLayoutSize.extraLarge => spacing.xxxl,
    };

    return EdgeInsets.symmetric(horizontal: horizontal, vertical: spacing.xl);
  }
}
