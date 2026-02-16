import 'package:flutter/material.dart';
import 'package:memuno_app/src/features/settings/application/providers/theme_preference_provider.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_theme.dart';
import 'package:memuno_app/src/infrastructure/platform/system_brightness_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_resolution_provider.g.dart';

/// Resolved theme configuration combining preference and system brightness.
final class ThemeResolution {
  /// Creates a theme resolution snapshot.
  const ThemeResolution({
    required this.preference,
    required this.systemBrightness,
  });

  /// User-selected preference.
  final AppTheme preference;

  /// Current system brightness.
  final Brightness systemBrightness;

  /// Theme to apply based on preference and system setting.
  AppTheme get resolvedTheme {
    if (preference == AppTheme.system) {
      return resolvedSystemTheme;
    }
    return preference;
  }

  /// Theme derived from the system brightness.
  AppTheme get resolvedSystemTheme {
    return _resolveForBrightness(systemBrightness);
  }
}

/// Provides the resolved theme configuration.
@Riverpod(keepAlive: true)
ThemeResolution themeResolution(Ref ref) {
  /// User preference.
  final AppTheme preference = ref.watch(themePreferenceProvider);

  /// Current system brightness.
  final Brightness systemBrightness = ref.watch(systemBrightnessProvider);

  return ThemeResolution(
    preference: preference,
    systemBrightness: systemBrightness,
  );
}

/// Resolves an [AppTheme] from the platform brightness.
AppTheme _resolveForBrightness(Brightness brightness) {
  return brightness == Brightness.light ? AppTheme.light : AppTheme.dark;
}
