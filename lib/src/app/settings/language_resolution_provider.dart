import 'package:flutter/widgets.dart';
import 'package:memuno_app/src/features/settings/application/providers/language_preference_provider.dart';
import 'package:memuno_app/src/features/settings/domain/entities/app_language.dart';
import 'package:memuno_app/src/infrastructure/platform/system_locale_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'language_resolution_provider.g.dart';

/// Resolved language configuration combining preference and system locale.
final class LanguageResolution {
  /// Creates a language resolution snapshot.
  const LanguageResolution({
    required this.preference,
    required this.systemLocale,
  });

  /// User-selected preference.
  final AppLanguage preference;

  /// Current system locale.
  final Locale systemLocale;

  /// Language to apply to the app.
  AppLanguage get resolvedLanguage {
    if (preference == AppLanguage.system) {
      return resolvedSystemLanguage;
    }
    return preference;
  }

  /// Language derived from the system locale.
  AppLanguage get resolvedSystemLanguage {
    return _resolveForLocale(systemLocale);
  }

  /// Locale to pass to [MaterialApp].
  Locale get resolvedLocale {
    final AppLanguage language = resolvedLanguage;
    final String? languageCode = language.languageCode;
    if (languageCode == null) {
      return systemLocale;
    }
    return Locale(languageCode, language.countryCode);
  }
}

/// Provides the resolved language configuration.
@Riverpod(keepAlive: true)
LanguageResolution languageResolution(Ref ref) {
  /// User preference.
  final AppLanguage preference = ref.watch(languagePreferenceProvider);

  /// Current system locale.
  final Locale systemLocale = ref.watch(systemLocaleProvider);

  return LanguageResolution(preference: preference, systemLocale: systemLocale);
}

/// Resolves an [AppLanguage] from the current locale.
AppLanguage _resolveForLocale(Locale locale) {
  for (final AppLanguage language in AppLanguage.values) {
    if (language == AppLanguage.system) {
      continue;
    }
    if (language.languageCode == locale.languageCode &&
        language.countryCode == locale.countryCode) {
      return language;
    }
  }
  for (final AppLanguage language in AppLanguage.values) {
    if (language == AppLanguage.system) {
      continue;
    }
    if (language.languageCode == locale.languageCode &&
        language.defaultForLanguageCode) {
      return language;
    }
  }
  return AppLanguage.enUS;
}
