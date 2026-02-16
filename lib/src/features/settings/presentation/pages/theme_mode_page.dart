import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/layout/app_layout.dart';
import 'package:memuno_app/src/app/settings/theme_resolution_provider.dart';
import 'package:memuno_app/src/app/widgets/app_app_bar.dart';
import 'package:memuno_app/src/features/settings/application/providers/theme_preference_provider.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_theme.dart';

/// Page for selecting the preferred app theme mode.
class ThemeModePage extends ConsumerWidget {
  /// Creates the theme mode settings page.
  const ThemeModePage({super.key});

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppTheme selectedTheme = ref.watch(themePreferenceProvider);
    final ThemeResolution resolution = ref.watch(themeResolutionProvider);
    final spacing = context.spacing;
    final double formMaxWidth = AppLayout.formMaxWidthFor(context.screenWidth);

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.settingsThemeModeTitle,
        subtitle: l10n.settingsThemeModeSubtitle,
        onBack: () => context.pop(),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: AppLayout.pagePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: formMaxWidth),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(spacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selectedTheme == AppTheme.system
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(l10n.settingsThemeModeSystemOption),
                      subtitle: Text(
                        l10n.settingsThemeModeSystemDescription(
                          _themeLabel(resolution.resolvedSystemTheme, l10n),
                        ),
                      ),
                      onTap: () => _setTheme(ref, AppTheme.system),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selectedTheme == AppTheme.light
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(l10n.settingsThemeModeLightOption),
                      onTap: () => _setTheme(ref, AppTheme.light),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selectedTheme == AppTheme.dark
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(l10n.settingsThemeModeDarkOption),
                      onTap: () => _setTheme(ref, AppTheme.dark),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Updates the selected theme preference.
  void _setTheme(WidgetRef ref, AppTheme theme) {
    ref.read(themePreferenceProvider.notifier).setTheme(theme);
  }

  /// Resolves the localized label for a theme option.
  String _themeLabel(AppTheme theme, AppLocalizations l10n) {
    return switch (theme) {
      AppTheme.system => l10n.settingsThemeModeSystemOption,
      AppTheme.light => l10n.settingsThemeModeLightOption,
      AppTheme.dark => l10n.settingsThemeModeDarkOption,
    };
  }
}
