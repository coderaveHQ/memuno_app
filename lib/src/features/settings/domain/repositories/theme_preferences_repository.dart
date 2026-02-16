import 'package:memuno_app/src/features/settings/domain/entities/app_theme.dart';

/// Repository for theme preference persistence.
abstract class ThemePreferencesRepository {
  /// Loads the last saved theme preference.
  AppTheme? loadTheme();

  /// Saves the selected theme preference.
  Future<void> saveTheme(AppTheme theme);
}
