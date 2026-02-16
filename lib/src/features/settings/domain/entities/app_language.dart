/// Language preference selected by the user.
enum AppLanguage {
  /// Follow the system locale.
  system(),

  /// English (United States).
  enUS(languageCode: 'en', countryCode: 'US', defaultForLanguageCode: true),

  /// German (Germany).
  deDE(languageCode: 'de', countryCode: 'DE', defaultForLanguageCode: true);

  /// ISO 639-1 language code.
  final String? languageCode;

  /// ISO 3166-1 alpha-2 country code.
  final String? countryCode;

  /// Whether this entry is the default for its language code.
  final bool defaultForLanguageCode;

  /// Creates an AppLanguage instance.
  const AppLanguage({
    this.languageCode,
    this.countryCode,
    this.defaultForLanguageCode = false,
  });

  /// Native label shown in language pickers.
  ///
  /// We intentionally keep these labels in their own language so users can
  /// recognize target languages regardless of current app locale.
  String get nativeLabel {
    return switch (this) {
      AppLanguage.system => 'System',
      AppLanguage.enUS => 'English (US)',
      AppLanguage.deDE => 'Deutsch (Deutschland)',
    };
  }

  /// Persisted key for this language preference.
  String get storageKey {
    if (this == AppLanguage.system) {
      return 'system';
    }
    return '${languageCode}_$countryCode';
  }

  /// Parses a stored key into an [AppLanguage].
  static AppLanguage? fromStorageKey(String? key) {
    if (key == null) {
      return null;
    }
    for (final AppLanguage language in AppLanguage.values) {
      if (language.storageKey == key) {
        return language;
      }
    }
    return null;
  }
}
