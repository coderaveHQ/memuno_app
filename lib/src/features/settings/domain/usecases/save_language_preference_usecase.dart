import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/language_preferences_repository.dart';

/// Usecase: persist the selected language preference.
final class SaveLanguagePreferenceUsecase {
  /// Creates the usecase.
  const SaveLanguagePreferenceUsecase({
    /// Repository used to save preferences.
    required LanguagePreferencesRepository repository,
  }) : _repository = repository;

  /// Repository used for preference storage.
  final LanguagePreferencesRepository _repository;

  /// Persists the language preference.
  Future<void> call(AppLanguage language) {
    return _repository.saveLanguage(language);
  }
}
