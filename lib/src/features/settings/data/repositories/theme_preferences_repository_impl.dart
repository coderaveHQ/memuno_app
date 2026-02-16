import 'package:memuno_app/src/features/settings/data/datasources/theme_preferences_local_datasource.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_theme.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/theme_preferences_repository.dart';

/// Repository implementation for theme preferences.
final class ThemePreferencesRepositoryImpl
    implements ThemePreferencesRepository {
  /// Creates the repository.
  const ThemePreferencesRepositoryImpl({
    required ThemePreferencesLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final ThemePreferencesLocalDatasource _localDatasource;

  @override
  /// Loads the persisted theme preference.
  AppTheme? loadTheme() {
    final String? key = _localDatasource.loadTheme();
    return AppTheme.fromStorageKey(key);
  }

  @override
  /// Persists the selected theme preference.
  Future<void> saveTheme(AppTheme theme) {
    return _localDatasource.saveTheme(theme.storageKey);
  }
}
