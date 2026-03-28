import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/app/widgets/sign_out_button.dart';
import 'package:memuno_app/src/core/config/legal_urls.dart';
import 'package:memuno_app/src/core/external/external_url_launcher.dart';
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

  Future<void> _openLegalDocument(
    BuildContext context,
    WidgetRef ref,
    LegalDocument document,
  ) async {
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Uri uri = LegalUrls.resolve(
      document: document,
      locale: Localizations.localeOf(context),
    );

    try {
      final bool opened = await ref.read(externalUrlLauncherProvider).open(uri);
      if (!opened && context.mounted) {
        feedback.showError(context, message: l10n.genericErrorMessage);
      }
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      feedback.resolveAndShowError(context, error);
    }
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

    final MAppBar appBar = MAppBar(
      context: context,
      title: MAppBarTitle(text: l10n.settingsTitle),
      leading: <MAppBarButton>[
        MAppBarButton(
          onPressed: () => _onBack(context),
          icon: LucideIcons.arrow_left,
        ),
      ],
    );

    return MScaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Padding(
        padding: EdgeInsets.only(top: appBar.preferredSize.height - 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: 20.0 + MSpacing.md),
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: titlePadding,
                      child: MText.h3(
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
                      child: MText.h3(
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
                  MListTile(
                    onPressed: () {
                      const BlockedUsersRoute().push<void>(context);
                    },
                    title: l10n.settingsBlockedUsersTitle,
                    description: l10n.settingsBlockedUsersSubtitle,
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
                      child: MText.h3(
                        text: l10n.settingsSectionLegal,
                        style: TextStyle(color: MColors.gray100),
                      ),
                    ),
                  ),
                  const MGap.sm(),
                  MListTile(
                    onPressed: () {
                      _openLegalDocument(
                        context,
                        ref,
                        LegalDocument.privacyPolicy,
                      );
                    },
                    title: l10n.settingsLegalPrivacyTitle,
                    description: l10n.settingsLegalPrivacySubtitle,
                    trailing: const Icon(
                      LucideIcons.chevron_right,
                      color: MColors.gray500,
                      size: 24.0,
                    ),
                    padding: tilePadding,
                  ),
                  MListTile(
                    onPressed: () {
                      _openLegalDocument(
                        context,
                        ref,
                        LegalDocument.termsOfUse,
                      );
                    },
                    title: l10n.settingsLegalTermsTitle,
                    description: l10n.settingsLegalTermsSubtitle,
                    trailing: const Icon(
                      LucideIcons.chevron_right,
                      color: MColors.gray500,
                      size: 24.0,
                    ),
                    padding: tilePadding,
                  ),
                  MListTile(
                    onPressed: () {
                      _openLegalDocument(
                        context,
                        ref,
                        LegalDocument.communityGuidelines,
                      );
                    },
                    title: l10n.settingsLegalCommunityTitle,
                    description: l10n.settingsLegalCommunitySubtitle,
                    trailing: const Icon(
                      LucideIcons.chevron_right,
                      color: MColors.gray500,
                      size: 24.0,
                    ),
                    padding: tilePadding,
                  ),
                  MListTile(
                    onPressed: () {
                      _openLegalDocument(context, ref, LegalDocument.impressum);
                    },
                    title: l10n.settingsLegalImpressumTitle,
                    description: l10n.settingsLegalImpressumSubtitle,
                    trailing: const Icon(
                      LucideIcons.chevron_right,
                      color: MColors.gray500,
                      size: 24.0,
                    ),
                    padding: tilePadding,
                  ),
                  MListTile(
                    onPressed: () {
                      _openLegalDocument(context, ref, LegalDocument.support);
                    },
                    title: l10n.settingsLegalSupportTitle,
                    description: l10n.settingsLegalSupportSubtitle,
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
              padding: EdgeInsets.only(
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
                top: MSpacing.md,
                bottom: context.bottomPadding + MSpacing.md,
              ),
              child: const SignOutButton(),
            ),
          ],
        ),
      ),
    );
  }
}
