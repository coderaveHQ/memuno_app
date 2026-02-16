import 'package:memuno_app/src/features/settings/application/providers/language_preferences_datasource_provider.dart';
import 'package:memuno_app/src/features/settings/data/datasources/language_preferences_local_datasource.dart';
import 'package:memuno_app/src/features/settings/data/repositories/language_preferences_repository_impl.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/language_preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_preferences_repository_provider.g.dart';

/// Provides the [LanguagePreferencesRepository].
@Riverpod(keepAlive: true)
LanguagePreferencesRepository languagePreferencesRepository(Ref ref) {
  /// Local datasource dependency.
  final LanguagePreferencesLocalDatasource localDatasource = ref.watch(
    languagePreferencesLocalDatasourceProvider,
  );
  // Construct the repository with its dependencies.
  return LanguagePreferencesRepositoryImpl(localDatasource: localDatasource);
}
