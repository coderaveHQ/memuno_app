import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/layout/app_layout.dart';
import 'package:memuno_app/src/app/settings/language_resolution_provider.dart';
import 'package:memuno_app/src/app/widgets/app_app_bar.dart';
import 'package:memuno_app/src/features/settings/application/providers/language_preference_provider.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';

/// Page for selecting the preferred app language mode.
class LanguageModePage extends ConsumerWidget {
  /// Creates the language mode settings page.
  const LanguageModePage({super.key});

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLanguage selectedLanguage = ref.watch(languagePreferenceProvider);
    final LanguageResolution resolution = ref.watch(languageResolutionProvider);
    final spacing = context.spacing;
    final double formMaxWidth = AppLayout.formMaxWidthFor(context.screenWidth);

    return Scaffold(
      appBar: AppAppBar(
        title: l10n.settingsLanguageModeTitle,
        subtitle: l10n.settingsLanguageModeSubtitle,
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
                        selectedLanguage == AppLanguage.system
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(l10n.settingsLanguageModeSystemOption),
                      subtitle: Text(
                        l10n.settingsLanguageModeSystemDescription(
                          _languageLabel(
                            resolution.resolvedSystemLanguage,
                            l10n,
                          ),
                        ),
                      ),
                      onTap: () => _setLanguage(ref, AppLanguage.system),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selectedLanguage == AppLanguage.enUS
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(AppLanguage.enUS.nativeLabel),
                      onTap: () => _setLanguage(ref, AppLanguage.enUS),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        selectedLanguage == AppLanguage.deDE
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(AppLanguage.deDE.nativeLabel),
                      onTap: () => _setLanguage(ref, AppLanguage.deDE),
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

  /// Updates the selected language preference.
  void _setLanguage(WidgetRef ref, AppLanguage language) {
    ref.read(languagePreferenceProvider.notifier).setLanguage(language);
  }

  /// Resolves the localized label for a language option.
  String _languageLabel(AppLanguage language, AppLocalizations l10n) {
    if (language == AppLanguage.system) {
      return l10n.settingsLanguageModeSystemOption;
    }
    return language.nativeLabel;
  }
}
