import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence for theme preferences.
abstract class ThemePreferencesLocalDatasource {
  /// Loads the stored theme key, if any.
  String? loadTheme();

  /// Saves the theme storage key.
  Future<void> saveTheme(String key);
}

/// SharedPreferences-backed implementation.
final class ThemePreferencesLocalDatasourceImpl
    implements ThemePreferencesLocalDatasource {
  /// Creates the datasource.
  const ThemePreferencesLocalDatasourceImpl({
    required SharedPreferences sharedPreferences,
  }) : _sharedPreferences = sharedPreferences;

  static const String _themeKey = 'settings.theme';

  final SharedPreferences _sharedPreferences;

  @override
  /// Loads the persisted theme preference.
  String? loadTheme() {
    return _sharedPreferences.getString(_themeKey);
  }

  @override
  /// Persists the selected theme preference.
  Future<void> saveTheme(String key) async {
    await _sharedPreferences.setString(_themeKey, key);
  }
}
