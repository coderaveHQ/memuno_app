/// Common breakpoints for responsive layouts.
enum AppLayoutSize { compact, medium, large, extraLarge }

/// Breakpoint values aligned with Material guidance.
final class AppBreakpoints {
  /// Creates a AppBreakpoints instance.
  const AppBreakpoints._();

  /// Compact screens: phones.
  static const double compact = 600;

  /// Medium screens: large phones / small tablets.
  static const double medium = 840;

  /// Large screens: tablets / small desktops.
  static const double large = 1200;

  /// Extra-large screens: desktop wide.
  static const double extraLarge = 1600;

  /// Resolves a width to a layout size bucket.
  static AppLayoutSize resolve(double width) {
    if (width < compact) {
      return AppLayoutSize.compact;
    }
    if (width < medium) {
      return AppLayoutSize.medium;
    }
    if (width < large) {
      return AppLayoutSize.large;
    }
    return AppLayoutSize.extraLarge;
  }
}
