import 'package:memuno_app/src/features/settings/application/providers/theme_preferences_datasource_provider.dart';
import 'package:memuno_app/src/features/settings/data/datasources/theme_preferences_local_datasource.dart';
import 'package:memuno_app/src/features/settings/data/repositories/theme_preferences_repository_impl.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/theme_preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_preferences_repository_provider.g.dart';

/// Provides the [ThemePreferencesRepository].
@Riverpod(keepAlive: true)
ThemePreferencesRepository themePreferencesRepository(Ref ref) {
  /// Local datasource dependency.
  final ThemePreferencesLocalDatasource localDatasource = ref.watch(
    themePreferencesLocalDatasourceProvider,
  );
  // Construct the repository with its dependencies.
  return ThemePreferencesRepositoryImpl(localDatasource: localDatasource);
}
