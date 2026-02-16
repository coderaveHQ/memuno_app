import 'package:memuno_app/src/features/settings/application/providers/theme_preferences_repository_provider.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/theme_preferences_repository.dart';
import 'package:memuno_app/src/features/settings/domain/usecases/load_theme_preference_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_theme_preference_usecase_provider.g.dart';

/// Provides the [LoadThemePreferenceUsecase] usecase.
@riverpod
LoadThemePreferenceUsecase loadThemePreferenceUsecase(Ref ref) {
  /// Repository dependency for the usecase.
  final ThemePreferencesRepository repository = ref.watch(
    themePreferencesRepositoryProvider,
  );
  // Construct the usecase with its dependencies.
  return LoadThemePreferenceUsecase(repository: repository);
}
