import 'package:memuno_app/src/features/settings/application/providers/usecases/load_theme_preference_usecase_provider.dart';
import 'package:memuno_app/src/features/settings/application/providers/usecases/save_theme_preference_usecase_provider.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_theme.dart';
import 'package:memuno_app/src/features/settings/domain/usecases/load_theme_preference_usecase.dart';
import 'package:memuno_app/src/features/settings/domain/usecases/save_theme_preference_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_preference_provider.g.dart';

/// Stores the user's theme preference.
@Riverpod(keepAlive: true)
class ThemePreference extends _$ThemePreference {
  @override
  /// Builds and returns the widget tree for this component.
  AppTheme build() {
    return _loadPersistedTheme() ?? AppTheme.system;
  }

  /// Returns load persisted theme.
  AppTheme? _loadPersistedTheme() {
    final LoadThemePreferenceUsecase loadTheme = ref.watch(
      loadThemePreferenceUsecaseProvider,
    );
    return loadTheme();
  }

  /// Updates and persists the preferred theme.
  Future<void> setTheme(AppTheme theme) async {
    state = theme;
    final SaveThemePreferenceUsecase saveTheme = ref.read(
      saveThemePreferenceUsecaseProvider,
    );
    await saveTheme(theme);
  }
}
