import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/settings/language_resolution_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_radio_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/settings/application/providers/language_preference_provider.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';

/// Page for selecting the preferred app language mode.
class LanguageModePage extends ConsumerWidget {
  /// Creates the language mode settings page.
  const LanguageModePage({super.key});

  void _onBack(BuildContext context) {
    context.pop();
  }

  /// Updates the selected language preference.
  void _setLanguage(WidgetRef ref, AppLanguage language) {
    ref.read(languagePreferenceProvider.notifier).setLanguage(language);
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
    final AppLanguage selectedLanguage = ref.watch(languagePreferenceProvider);
    final LanguageResolution resolution = ref.watch(languageResolutionProvider);

    final EdgeInsetsGeometry tilePadding = EdgeInsets.only(
      top: MSpacing.md,
      bottom: MSpacing.md,
      left: context.leftPadding + MSpacing.md,
      right: context.rightPadding + MSpacing.md,
    );

    final MAppBar appBar = MAppBar(
      context: context,
      title: MAppBarTitle(text: l10n.languageModeTitle),
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
        child: ListView(
          padding: EdgeInsets.only(
            top: 20.0 + MSpacing.md,
            bottom: context.bottomPadding,
          ),
          children: <Widget>[
            MListTile(
              onPressed: () => _setLanguage(ref, AppLanguage.system),
              title: l10n.languageModeSystemOption,
              description: l10n.languageModeSystemDescription(
                _languageLabel(resolution.resolvedSystemLanguage, l10n),
              ),
              padding: tilePadding,
              trailing: MRadioIndicator(
                isSelected: selectedLanguage == AppLanguage.system,
              ),
            ),
            MListTile(
              onPressed: () => _setLanguage(ref, AppLanguage.enUS),
              title: AppLanguage.enUS.nativeLabel,
              description: l10n.languageModeSystemDescription(
                _languageLabel(resolution.resolvedSystemLanguage, l10n),
              ),
              padding: tilePadding,
              trailing: MRadioIndicator(
                isSelected: selectedLanguage == AppLanguage.enUS,
              ),
            ),
            MListTile(
              onPressed: () => _setLanguage(ref, AppLanguage.deDE),
              title: AppLanguage.deDE.nativeLabel,
              padding: tilePadding,
              trailing: MRadioIndicator(
                isSelected: selectedLanguage == AppLanguage.deDE,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
