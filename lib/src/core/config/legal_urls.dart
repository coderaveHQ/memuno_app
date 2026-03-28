import 'package:flutter/widgets.dart';
import 'package:memuno_app/src/core/config/app_env.dart';

/// Canonical legal documents hosted on the static legal site.
enum LegalDocument {
  privacyPolicy,
  termsOfUse,
  communityGuidelines,

  /// Not used currently since account deletion is handled in-app, but we keep it here for future use.
  accountDeletion,
  support,
  impressum,
}

/// Resolves environment and locale-aware legal URLs.
final class LegalUrls {
  const LegalUrls._();

  static const Map<LegalDocument, String> _pathByDocument =
      <LegalDocument, String>{
        LegalDocument.privacyPolicy: 'privacy-policy',
        LegalDocument.termsOfUse: 'terms-of-use',
        LegalDocument.communityGuidelines: 'community-guidelines',
        LegalDocument.accountDeletion: 'account-deletion',
        LegalDocument.support: 'support',
        LegalDocument.impressum: 'impressum',
      };

  /// Returns one hosted URL for the given [document] and [locale].
  static Uri resolve({
    required LegalDocument document,
    required Locale locale,
  }) {
    final String base = AppEnv.legalBaseUrl;
    final String localeSegment = _resolveLocaleSegment(locale);
    final String documentPath = _pathByDocument[document]!;

    return Uri.parse('$base/$localeSegment/$documentPath/');
  }

  static String _resolveLocaleSegment(Locale locale) {
    final String language = locale.languageCode.toLowerCase();
    final String? country = locale.countryCode?.toUpperCase();

    if (language == 'de') {
      if (country == 'DE') {
        return 'de-DE';
      }
      return 'de';
    }

    if (country == 'US') {
      return 'en-US';
    }
    return 'en';
  }
}
