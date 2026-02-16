import 'package:memuno_app/src/features/settings/domain/entities/app_theme.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/theme_preferences_repository.dart';

/// Usecase: load the persisted theme preference.
final class LoadThemePreferenceUsecase {
  /// Creates the usecase.
  const LoadThemePreferenceUsecase({
    /// Repository used to load preferences.
    required ThemePreferencesRepository repository,
  }) : _repository = repository;

  /// Repository used for preference storage.
  final ThemePreferencesRepository _repository;

  /// Loads the saved theme preference, if any.
  AppTheme? call() {
    return _repository.loadTheme();
  }
}
