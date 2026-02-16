import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for language preferences.
abstract class LanguagePreferencesLocalDatasource {
  /// Loads the stored language key, if any.
  String? loadLanguage();

  /// Saves the language storage key.
  Future<void> saveLanguage(String key);
}

/// SharedPreferences-backed implementation.
final class LanguagePreferencesLocalDatasourceImpl
    implements LanguagePreferencesLocalDatasource {
  /// Creates the datasource.
  const LanguagePreferencesLocalDatasourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  static const String _languageKey = 'settings.language';

  final SharedPreferences _sharedPreferences;

  @override
  /// Loads the persisted language preference.
  String? loadLanguage() {
    return _sharedPreferences.getString(_languageKey);
  }

  @override
  /// Persists the selected language preference.
  Future<void> saveLanguage(String key) async {
    await _sharedPreferences.setString(_languageKey, key);
  }
}
