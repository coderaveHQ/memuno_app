import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/language_preferences_repository.dart';

/// Usecase: load the persisted language preference.
final class LoadLanguagePreferenceUsecase {
  /// Creates the usecase.
  const LoadLanguagePreferenceUsecase({
    /// Repository used to load preferences.
    required LanguagePreferencesRepository repository,
  }) : _repository = repository;

  /// Repository used for preference storage.
  final LanguagePreferencesRepository _repository;

  /// Loads the saved language preference, if any.
  AppLanguage? call() {
    return _repository.loadLanguage();
  }
}
