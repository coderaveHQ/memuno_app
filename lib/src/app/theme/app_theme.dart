import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';
import 'package:memuno_app/src/app/theme/app_spacing.dart';

/// Centralized theme configuration for the app.
final class AppTheme {
  /// Returns the light theme.
  static ThemeData light() {
    return _buildTheme(AppShadColors.light, Brightness.light);
  }

  /// Returns the dark theme.
  static ThemeData dark() {
    return _buildTheme(AppShadColors.dark, Brightness.dark);
  }

  /// Returns build theme.
  static ThemeData _buildTheme(AppShadColors colors, Brightness brightness) {
    final ColorScheme baseScheme = brightness == Brightness.light
        ? ColorScheme.light(
            primary: colors.primary,
            onPrimary: colors.primaryForeground,
            secondary: colors.secondary,
            onSecondary: colors.secondaryForeground,
            error: colors.destructive,
            onError: colors.destructiveForeground,
            surface: colors.background,
            onSurface: colors.foreground,
            outline: colors.border,
          )
        : ColorScheme.dark(
            primary: colors.primary,
            onPrimary: colors.primaryForeground,
            secondary: colors.secondary,
            onSecondary: colors.secondaryForeground,
            error: colors.destructive,
            onError: colors.destructiveForeground,
            surface: colors.background,
            onSurface: colors.foreground,
            outline: colors.border,
          );

    final ColorScheme scheme = baseScheme.copyWith(
      surfaceContainerHighest: colors.muted,
    );

    final TextTheme baseTextTheme = ThemeData(brightness: brightness).textTheme
        .apply(
          fontFamily: 'Switzer',
          bodyColor: colors.foreground,
          displayColor: colors.foreground,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Switzer',
      scaffoldBackgroundColor: colors.background,
      textTheme: baseTextTheme,
      extensions: <ThemeExtension<dynamic>>[colors, const AppSpacing()],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: colors.foreground,
        ),
      ),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: colors.foreground),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.ring,
        selectionColor: colors.ring.withValues(alpha: 0.2),
        selectionHandleColor: colors.ring,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.input),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.input),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.ring, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.destructive),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colors.destructive, width: 2),
        ),
        labelStyle: baseTextTheme.bodyMedium?.copyWith(
          color: colors.mutedForeground,
        ),
        hintStyle: baseTextTheme.bodyMedium?.copyWith(
          color: colors.mutedForeground,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.card,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: colors.cardForeground,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border),
        ),
      ),
    );
  }
}
