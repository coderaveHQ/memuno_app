import 'package:flutter/material.dart';

/// Tailwind Zinc palette used by the shadcn theme.
final class AppZinc {
  /// Creates a AppZinc instance.
  const AppZinc._();

  static const Color zinc50 = Color(0xFFFAFAFA);
  static const Color zinc100 = Color(0xFFF4F4F5);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc950 = Color(0xFF09090B);
}

/// Theme tokens aligned with shadcn's zinc palette.
@immutable
final class AppShadColors extends ThemeExtension<AppShadColors> {
  /// Creates an AppShadColors instance.
  const AppShadColors({
    required this.background,
    required this.foreground,
    required this.card,
    required this.cardForeground,
    required this.popover,
    required this.popoverForeground,
    required this.primary,
    required this.primaryForeground,
    required this.secondary,
    required this.secondaryForeground,
    required this.muted,
    required this.mutedForeground,
    required this.accent,
    required this.accentForeground,
    required this.destructive,
    required this.destructiveForeground,
    required this.border,
    required this.input,
    required this.ring,
    required this.success,
    required this.successForeground,
    required this.warning,
    required this.warningForeground,
    required this.info,
    required this.infoForeground,
  });

  final Color background;
  final Color foreground;
  final Color card;
  final Color cardForeground;
  final Color popover;
  final Color popoverForeground;
  final Color primary;
  final Color primaryForeground;
  final Color secondary;
  final Color secondaryForeground;
  final Color muted;
  final Color mutedForeground;
  final Color accent;
  final Color accentForeground;
  final Color destructive;
  final Color destructiveForeground;
  final Color border;
  final Color input;
  final Color ring;
  final Color success;
  final Color successForeground;
  final Color warning;
  final Color warningForeground;
  final Color info;
  final Color infoForeground;

  /// Light zinc theme tokens.
  static const AppShadColors light = AppShadColors(
    background: Colors.white,
    foreground: AppZinc.zinc950,
    card: Colors.white,
    cardForeground: AppZinc.zinc950,
    popover: Colors.white,
    popoverForeground: AppZinc.zinc950,
    primary: AppZinc.zinc900,
    primaryForeground: AppZinc.zinc50,
    secondary: AppZinc.zinc100,
    secondaryForeground: AppZinc.zinc900,
    muted: AppZinc.zinc100,
    mutedForeground: AppZinc.zinc500,
    accent: AppZinc.zinc100,
    accentForeground: AppZinc.zinc900,
    destructive: Color(0xFFEF4444),
    destructiveForeground: AppZinc.zinc50,
    border: AppZinc.zinc200,
    input: AppZinc.zinc200,
    ring: AppZinc.zinc900,
    success: Color(0xFF16A34A),
    successForeground: Color(0xFFF0FDF4),
    warning: Color(0xFFF59E0B),
    warningForeground: Color(0xFFFFFBEB),
    info: Color(0xFF2563EB),
    infoForeground: Color(0xFFEFF6FF),
  );

  /// Dark zinc theme tokens.
  static const AppShadColors dark = AppShadColors(
    background: AppZinc.zinc950,
    foreground: AppZinc.zinc50,
    card: AppZinc.zinc950,
    cardForeground: AppZinc.zinc50,
    popover: AppZinc.zinc950,
    popoverForeground: AppZinc.zinc50,
    primary: AppZinc.zinc50,
    primaryForeground: AppZinc.zinc900,
    secondary: AppZinc.zinc800,
    secondaryForeground: AppZinc.zinc50,
    muted: AppZinc.zinc800,
    mutedForeground: AppZinc.zinc400,
    accent: AppZinc.zinc800,
    accentForeground: AppZinc.zinc50,
    destructive: Color(0xFF7F1D1D),
    destructiveForeground: Color(0xFFFEF2F2),
    border: AppZinc.zinc800,
    input: AppZinc.zinc800,
    ring: AppZinc.zinc300,
    success: Color(0xFF22C55E),
    successForeground: Color(0xFF052E16),
    warning: Color(0xFFF59E0B),
    warningForeground: Color(0xFF451A03),
    info: Color(0xFF60A5FA),
    infoForeground: Color(0xFF172554),
  );

  /// Returns the theme tokens from the current [Theme].
  static AppShadColors of(BuildContext context) {
    return Theme.of(context).extension<AppShadColors>() ?? light;
  }

  @override
  /// Returns a copy with selectively overridden values.
  AppShadColors copyWith({
    Color? background,
    Color? foreground,
    Color? card,
    Color? cardForeground,
    Color? popover,
    Color? popoverForeground,
    Color? primary,
    Color? primaryForeground,
    Color? secondary,
    Color? secondaryForeground,
    Color? muted,
    Color? mutedForeground,
    Color? accent,
    Color? accentForeground,
    Color? destructive,
    Color? destructiveForeground,
    Color? border,
    Color? input,
    Color? ring,
    Color? success,
    Color? successForeground,
    Color? warning,
    Color? warningForeground,
    Color? info,
    Color? infoForeground,
  }) {
    return AppShadColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      card: card ?? this.card,
      cardForeground: cardForeground ?? this.cardForeground,
      popover: popover ?? this.popover,
      popoverForeground: popoverForeground ?? this.popoverForeground,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      secondary: secondary ?? this.secondary,
      secondaryForeground: secondaryForeground ?? this.secondaryForeground,
      muted: muted ?? this.muted,
      mutedForeground: mutedForeground ?? this.mutedForeground,
      accent: accent ?? this.accent,
      accentForeground: accentForeground ?? this.accentForeground,
      destructive: destructive ?? this.destructive,
      destructiveForeground:
          destructiveForeground ?? this.destructiveForeground,
      border: border ?? this.border,
      input: input ?? this.input,
      ring: ring ?? this.ring,
      success: success ?? this.success,
      successForeground: successForeground ?? this.successForeground,
      warning: warning ?? this.warning,
      warningForeground: warningForeground ?? this.warningForeground,
      info: info ?? this.info,
      infoForeground: infoForeground ?? this.infoForeground,
    );
  }

  @override
  /// Linearly interpolates between two values.
  AppShadColors lerp(ThemeExtension<AppShadColors>? other, double t) {
    if (other is! AppShadColors) {
      return this;
    }
    return AppShadColors(
      background: Color.lerp(background, other.background, t)!,
      foreground: Color.lerp(foreground, other.foreground, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardForeground: Color.lerp(cardForeground, other.cardForeground, t)!,
      popover: Color.lerp(popover, other.popover, t)!,
      popoverForeground: Color.lerp(
        popoverForeground,
        other.popoverForeground,
        t,
      )!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryForeground: Color.lerp(
        primaryForeground,
        other.primaryForeground,
        t,
      )!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      secondaryForeground: Color.lerp(
        secondaryForeground,
        other.secondaryForeground,
        t,
      )!,
      muted: Color.lerp(muted, other.muted, t)!,
      mutedForeground: Color.lerp(mutedForeground, other.mutedForeground, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentForeground: Color.lerp(
        accentForeground,
        other.accentForeground,
        t,
      )!,
      destructive: Color.lerp(destructive, other.destructive, t)!,
      destructiveForeground: Color.lerp(
        destructiveForeground,
        other.destructiveForeground,
        t,
      )!,
      border: Color.lerp(border, other.border, t)!,
      input: Color.lerp(input, other.input, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
      success: Color.lerp(success, other.success, t)!,
      successForeground: Color.lerp(
        successForeground,
        other.successForeground,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningForeground: Color.lerp(
        warningForeground,
        other.warningForeground,
        t,
      )!,
      info: Color.lerp(info, other.info, t)!,
      infoForeground: Color.lerp(infoForeground, other.infoForeground, t)!,
    );
  }
}
