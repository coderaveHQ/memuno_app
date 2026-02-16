import 'package:memuno_app/src/features/settings/data/datasources/language_preferences_local_datasource.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/language_preferences_repository.dart';

/// Repository implementation for language preferences.
final class LanguagePreferencesRepositoryImpl
    implements LanguagePreferencesRepository {
  /// Creates the repository.
  const LanguagePreferencesRepositoryImpl({
    required LanguagePreferencesLocalDatasource localDatasource,
  }) : _localDatasource = localDatasource;

  final LanguagePreferencesLocalDatasource _localDatasource;

  @override
  /// Loads the persisted language preference.
  AppLanguage? loadLanguage() {
    final String? key = _localDatasource.loadLanguage();
    return AppLanguage.fromStorageKey(key);
  }

  @override
  /// Persists the selected language preference.
  Future<void> saveLanguage(AppLanguage language) {
    return _localDatasource.saveLanguage(language.storageKey);
  }
}
