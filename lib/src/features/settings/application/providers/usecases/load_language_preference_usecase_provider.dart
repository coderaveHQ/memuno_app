import 'package:memuno_app/src/features/settings/application/providers/language_preferences_repository_provider.dart';
import 'package:memuno_app/src/features/settings/domain/repositories/language_preferences_repository.dart';
import 'package:memuno_app/src/features/settings/domain/usecases/load_language_preference_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_language_preference_usecase_provider.g.dart';

/// Provides the [LoadLanguagePreferenceUsecase] usecase.
@riverpod
LoadLanguagePreferenceUsecase loadLanguagePreferenceUsecase(Ref ref) {
  /// Repository dependency for the usecase.
  final LanguagePreferencesRepository repository = ref.watch(
    languagePreferencesRepositoryProvider,
  );
  // Construct the usecase with its dependencies.
  return LoadLanguagePreferenceUsecase(repository: repository);
}
