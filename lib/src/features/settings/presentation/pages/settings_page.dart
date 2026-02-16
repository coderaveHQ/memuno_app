import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/layout/app_layout.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';
import 'package:memuno_app/src/app/widgets/app_app_bar.dart';
import 'package:memuno_app/src/app/widgets/app_gap.dart';
import 'package:memuno_app/src/features/auth/presentation/widgets/sign_out_button.dart';
import 'package:memuno_app/src/features/settings/application/providers/language_preference_provider.dart';
import 'package:memuno_app/src/features/settings/application/providers/theme_preference_provider.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_theme.dart';

/// Settings page for account and app preferences.
class SettingsPage extends ConsumerWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppTheme themePreference = ref.watch(themePreferenceProvider);
    final AppLanguage languagePreference = ref.watch(
      languagePreferenceProvider,
    );
    final AppShadColors colors = AppShadColors.of(context);
    final spacing = context.spacing;
    final double formMaxWidth = AppLayout.formMaxWidthFor(context.screenWidth);

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.settingsTitle,
        subtitle: l10n.settingsSubtitle,
        onBack: () => context.pop(),
      ),
      body: Center(
        child: Padding(
          padding: AppLayout.pagePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: formMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text(
                          l10n.settingsSectionAppearance,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        AppGap.v(spacing.sm),
                        Card(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(l10n.settingsThemeModeTitle),
                                subtitle: Text(
                                  _themeLabel(themePreference, l10n),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  const ThemeModeRoute().push<void>(context);
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                title: Text(l10n.settingsLanguageModeTitle),
                                subtitle: Text(
                                  _languageLabel(languagePreference, l10n),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  const LanguageModeRoute().push<void>(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        AppGap.v(spacing.xl),
                        Text(
                          l10n.settingsSectionAccountManagement,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        AppGap.v(spacing.sm),
                        Card(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Text(
                                  l10n.settingsChangeEmailListTileTitle,
                                ),
                                subtitle: Text(
                                  l10n.settingsChangeEmailListTileSubtitle,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  const ChangeEmailRoute().push<void>(context);
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                title: Text(
                                  l10n.settingsChangePasswordListTileTitle,
                                ),
                                subtitle: Text(
                                  l10n.settingsChangePasswordListTileSubtitle,
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  const ChangePasswordRoute().push<void>(
                                    context,
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                title: Text(
                                  l10n.settingsDeleteAccountListTileTitle,
                                  style: TextStyle(color: colors.destructive),
                                ),
                                subtitle: Text(
                                  l10n.settingsDeleteAccountListTileSubtitle,
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: colors.destructive,
                                ),
                                onTap: () {
                                  const DeleteAccountRoute().push<void>(
                                    context,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AppGap.v(spacing.lg),
                const SignOutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Resolves the localized label for a theme option.
  String _themeLabel(AppTheme theme, AppLocalizations l10n) {
    return switch (theme) {
      AppTheme.system => l10n.settingsThemeModeSystemOption,
      AppTheme.light => l10n.settingsThemeModeLightOption,
      AppTheme.dark => l10n.settingsThemeModeDarkOption,
    };
  }

  /// Resolves the localized label for a language option.
  String _languageLabel(AppLanguage language, AppLocalizations l10n) {
    if (language == AppLanguage.system) {
      return l10n.settingsLanguageModeSystemOption;
    }
    return language.nativeLabel;
  }
}
