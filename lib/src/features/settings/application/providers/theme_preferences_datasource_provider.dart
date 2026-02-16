import 'package:memuno_app/src/features/settings/data/datasources/theme_preferences_local_datasource.dart';
import 'package:memuno_app/src/infrastructure/shared_preferences/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_preferences_datasource_provider.g.dart';

/// Provides the [ThemePreferencesLocalDatasource].
@Riverpod(keepAlive: true)
ThemePreferencesLocalDatasource themePreferencesLocalDatasource(Ref ref) {
  /// SharedPreferences dependency for local storage.
  final SharedPreferences sharedPreferences = ref.watch(
    sharedPreferencesProvider,
  );
  // Use the SharedPreferences-backed datasource implementation.
  return ThemePreferencesLocalDatasourceImpl(
    sharedPreferences: sharedPreferences,
  );
}
