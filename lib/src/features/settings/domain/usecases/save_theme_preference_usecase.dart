import 'package:memuno_app/src/features/settings/domain/entities/app_theme.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/theme_preferences_repository.dart';

/// Usecase: persist the selected theme preference.
final class SaveThemePreferenceUsecase {
  /// Creates the usecase.
  const SaveThemePreferenceUsecase({
    /// Repository used to save preferences.
    required ThemePreferencesRepository repository,
  }) : _repository = repository;

  /// Repository used for preference storage.
  final ThemePreferencesRepository _repository;

  /// Persists the theme preference.
  Future<void> call(AppTheme theme) {
    return _repository.saveTheme(theme);
  }
}
