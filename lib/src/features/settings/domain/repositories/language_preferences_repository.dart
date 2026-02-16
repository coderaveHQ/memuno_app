import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';

/// Repository for language preference persistence.
abstract class LanguagePreferencesRepository {
  /// Loads the last saved language preference.
  AppLanguage? loadLanguage();

  /// Saves the selected language preference.
  Future<void> saveLanguage(AppLanguage language);
}
