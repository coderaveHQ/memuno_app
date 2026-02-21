import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/auth/presentation/widgets/sign_out_button.dart';
import 'package:memuno_app/src/features/settings/application/providers/language_preference_provider.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';

/// Settings page for account and app preferences.
class SettingsPage extends ConsumerWidget {
  /// Creates the settings page.
  const SettingsPage({super.key});

  void _onBack(BuildContext context) {
    context.pop();
  }

  /// Resolves the localized label for a language option.
  String _languageLabel(AppLanguage language, AppLocalizations l10n) {
    if (language == AppLanguage.system) {
      return l10n.languageModeSystemOption;
    }
    return language.nativeLabel;
  }

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLanguage languagePreference = ref.watch(
      languagePreferenceProvider,
    );

    final EdgeInsetsGeometry titlePadding = EdgeInsets.only(
      left: context.leftPadding + MSpacing.md,
      right: context.rightPadding + MSpacing.md,
    );

    final EdgeInsetsGeometry tilePadding = EdgeInsets.only(
      top: MSpacing.md,
      bottom: MSpacing.md,
      left: context.leftPadding + MSpacing.md,
      right: context.rightPadding + MSpacing.md,
    );

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.settingsTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onBack(context),
            icon: LucideIcons.arrow_left,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: MSpacing.md),
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: titlePadding,
                    child: MText.h4(
                      text: l10n.settingsSectionAppearance,
                      style: TextStyle(color: MColors.gray100),
                    ),
                  ),
                ),
                const MGap.sm(),
                MListTile(
                  onPressed: () {
                    const LanguageModeRoute().push<void>(context);
                  },
                  title: l10n.languageModeTitle,
                  description: _languageLabel(languagePreference, l10n),
                  trailing: const Icon(
                    LucideIcons.chevron_right,
                    color: MColors.gray500,
                    size: 24.0,
                  ),
                  padding: tilePadding,
                ),
                const MGap.lg(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: titlePadding,
                    child: MText.h4(
                      text: l10n.settingsSectionAccountManagement,
                      style: TextStyle(color: MColors.gray100),
                    ),
                  ),
                ),
                const MGap.sm(),
                MListTile(
                  onPressed: () {
                    const ChangeEmailRoute().push<void>(context);
                  },
                  title: l10n.changeEmailListTileTitle,
                  description: l10n.changeEmailListTileSubtitle,
                  trailing: const Icon(
                    LucideIcons.chevron_right,
                    color: MColors.gray500,
                    size: 24.0,
                  ),
                  padding: tilePadding,
                ),
                MListTile(
                  onPressed: () {
                    const ChangePasswordRoute().push<void>(context);
                  },
                  title: l10n.changePasswordListTileTitle,
                  description: l10n.changePasswordListTileSubtitle,
                  trailing: const Icon(
                    LucideIcons.chevron_right,
                    color: MColors.gray500,
                    size: 24.0,
                  ),
                  padding: tilePadding,
                ),
                MListTile(
                  onPressed: () {
                    const DeleteAccountRoute().push<void>(context);
                  },
                  title: l10n.deleteAccountListTileTitle,
                  description: l10n.deleteAccountListTileSubtitle,
                  trailing: const Icon(
                    LucideIcons.chevron_right,
                    color: MColors.gray500,
                    size: 24.0,
                  ),
                  padding: tilePadding,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.only(
              left: context.leftPadding + MSpacing.md,
              right: context.rightPadding + MSpacing.md,
              top: MSpacing.md,
              bottom: context.bottomPadding + MSpacing.md,
            ),
            child: const SignOutButton(),
          ),
        ],
      ),
    );
  }
}
