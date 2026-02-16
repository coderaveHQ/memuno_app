import 'package:memuno_app/src/features/settings/application/providers/usecases/load_language_preference_usecase_provider.dart';
import 'package:memuno_app/src/features/settings/application/providers/usecases/save_language_preference_usecase_provider.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';
import 'package:memuno_app/src/features/settings/domain/usecases/load_language_preference_usecase.dart';
import 'package:memuno_app/src/features/settings/domain/usecases/save_language_preference_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_preference_provider.g.dart';

/// Stores the user's language preference.
@Riverpod(keepAlive: true)
class LanguagePreference extends _$LanguagePreference {
  @override
  /// Builds and returns the widget tree for this component.
  AppLanguage build() {
    return _loadPersistedLanguage() ?? AppLanguage.system;
  }

  /// Returns load persisted language.
  AppLanguage? _loadPersistedLanguage() {
    final LoadLanguagePreferenceUsecase loadLanguage = ref.watch(
      loadLanguagePreferenceUsecaseProvider,
    );
    return loadLanguage();
  }

  /// Updates and persists the preferred language.
  Future<void> setLanguage(AppLanguage language) async {
    state = language;
    final SaveLanguagePreferenceUsecase saveLanguage = ref.read(
      saveLanguagePreferenceUsecaseProvider,
    );
    await saveLanguage(language);
  }
}
