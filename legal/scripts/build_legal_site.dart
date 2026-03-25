import 'dart:convert';
import 'dart:io';

const List<String> _canonicalLocales = <String>['en-US', 'de-DE'];
const Map<String, String> _localeAliases = <String, String>{
  'en': 'en-US',
  'de': 'de-DE',
};
const List<String> _documents = <String>[
  'privacy-policy',
  'terms-of-use',
  'community-guidelines',
  'account-deletion',
  'support',
  'impressum',
];
const List<String> _auxiliaryPages = <String>[
  'account-deletion-request',
  'account-deletion-confirm',
];
const List<String> _aliasRedirectPages = <String>[
  ..._documents,
  ..._auxiliaryPages,
];

const Map<String, Map<String, String>> _titles = <String, Map<String, String>>{
  'en-US': <String, String>{
    'privacy-policy': 'Privacy Policy',
    'terms-of-use': 'Terms of Use',
    'community-guidelines': 'Community Guidelines',
    'account-deletion': 'Account Deletion',
    'support': 'Support',
    'impressum': 'Impressum / Legal Notice',
  },
  'de-DE': <String, String>{
    'privacy-policy': 'Datenschutzerklärung',
    'terms-of-use': 'Nutzungsbedingungen',
    'community-guidelines': 'Community-Richtlinien',
    'account-deletion': 'Kontolöschung',
    'support': 'Support',
    'impressum': 'Impressum',
  },
};

const Map<String, Map<String, String>>
_requestPageText = <String, Map<String, String>>{
  'en-US': <String, String>{
    'page_title': 'Request Account Deletion',
    'intro':
        'Enter the email address for your account. We will send a secure verification link if the account exists.',
    'email_label': 'Email address',
    'email_placeholder': 'you@example.com',
    'submit_label': 'Send verification link',
    'sending_label': 'Sending...',
    'success_message':
        'If an account exists for this email, a verification link has been sent. For privacy reasons, you stay on this page.',
    'error_message': 'Could not submit the request. Please try again.',
    'back_link_label': 'Back to account deletion details',
  },
  'de-DE': <String, String>{
    'page_title': 'Kontolöschung anfragen',
    'intro':
        'Geben Sie die E-Mail-Adresse Ihres Kontos ein. Falls ein Konto existiert, senden wir einen sicheren Bestätigungslink.',
    'email_label': 'E-Mail-Adresse',
    'email_placeholder': 'du@beispiel.de',
    'submit_label': 'Bestätigungslink senden',
    'sending_label': 'Wird gesendet...',
    'success_message':
        'Falls ein Konto mit dieser E-Mail-Adresse existiert, wurde ein Bestätigungslink versendet. Aus Datenschutzgründen bleiben Sie auf dieser Seite.',
    'error_message':
        'Die Anfrage konnte nicht gesendet werden. Bitte versuchen Sie es erneut.',
    'back_link_label': 'Zurück zu den Infos zur Kontolöschung',
  },
};

const Map<String, Map<String, String>>
_confirmPageText = <String, Map<String, String>>{
  'en-US': <String, String>{
    'page_title': 'Confirm Account Deletion',
    'intro':
        'After email verification, confirm deletion here. This action permanently deletes your account.',
    'loading_message': 'Verifying your email session...',
    'ready_message':
        'Email verification succeeded. You can now permanently delete your account.',
    'not_verified_message':
        'This link is invalid or expired. Please request a new deletion link.',
    'verify_failed_message':
        'Could not verify this link. Please request a new deletion link.',
    'delete_button_label': 'Delete account permanently',
    'deleting_label': 'Deleting account...',
    'deleted_message': 'Your account has been deleted.',
    'delete_failed_message':
        'Could not delete your account. Please try again later.',
    'back_link_label': 'Back to account deletion details',
  },
  'de-DE': <String, String>{
    'page_title': 'Kontolöschung bestätigen',
    'intro':
        'Bestätigen Sie die Löschung nach erfolgreicher E-Mail-Verifizierung. Diese Aktion löscht Ihr Konto dauerhaft.',
    'loading_message': 'E-Mail-Sitzung wird verifiziert...',
    'ready_message':
        'E-Mail-Verifizierung erfolgreich. Sie können Ihr Konto jetzt dauerhaft löschen.',
    'not_verified_message':
        'Dieser Link ist ungültig oder abgelaufen. Bitte fordern Sie einen neuen Löschlink an.',
    'verify_failed_message':
        'Der Link konnte nicht verifiziert werden. Bitte fordern Sie einen neuen Löschlink an.',
    'delete_button_label': 'Konto dauerhaft löschen',
    'deleting_label': 'Konto wird gelöscht...',
    'deleted_message': 'Ihr Konto wurde gelöscht.',
    'delete_failed_message':
        'Ihr Konto konnte nicht gelöscht werden. Bitte versuchen Sie es später erneut.',
    'back_link_label': 'Zurück zu den Infos zur Kontolöschung',
  },
};

const List<_BuildEnvironment> _environments = <_BuildEnvironment>[
  _BuildEnvironment(
    name: 'development',
    configPath: 'legal/config/development.json',
    outputPrefix: 'development/legal',
  ),
  _BuildEnvironment(
    name: 'production',
    configPath: 'legal/config/production.json',
    outputPrefix: 'legal',
  ),
  _BuildEnvironment(
    name: 'staging',
    configPath: 'legal/config/staging.json',
    outputPrefix: 'staging/legal',
  ),
];

final class _BuildEnvironment {
  const _BuildEnvironment({
    required this.name,
    required this.configPath,
    required this.outputPrefix,
  });

  final String name;
  final String configPath;
  final String outputPrefix;
}

void main() {
  final String? versionOverride = _readVersionOverride();
  final Directory repoRoot = Directory.current;
  final Directory distDirectory = Directory(
    _join(repoRoot.path, <String>['legal', 'dist']),
  );

  if (distDirectory.existsSync()) {
    distDirectory.deleteSync(recursive: true);
  }
  distDirectory.createSync(recursive: true);

  final String pageTemplate = File(
    _join(repoRoot.path, <String>['legal', 'templates', 'page.html']),
  ).readAsStringSync();

  final String redirectTemplate = File(
    _join(repoRoot.path, <String>['legal', 'templates', 'redirect.html']),
  ).readAsStringSync();

  final String requestPageTemplate = File(
    _join(repoRoot.path, <String>[
      'legal',
      'templates',
      'account_deletion_request.html',
    ]),
  ).readAsStringSync();

  final String confirmPageTemplate = File(
    _join(repoRoot.path, <String>[
      'legal',
      'templates',
      'account_deletion_confirm.html',
    ]),
  ).readAsStringSync();

  for (final _BuildEnvironment environment in _environments) {
    final Map<String, String> config = _applyVersionOverride(
      _readConfig(_join(repoRoot.path, <String>[environment.configPath])),
      versionOverride,
    );

    for (final String locale in _canonicalLocales) {
      _buildCanonicalLocale(
        repoRoot: repoRoot,
        environment: environment,
        locale: locale,
        config: config,
        pageTemplate: pageTemplate,
        requestPageTemplate: requestPageTemplate,
        confirmPageTemplate: confirmPageTemplate,
      );

      final String localeIndexTarget = './${_documents.first}/';
      _writeFile(
        _join(repoRoot.path, <String>[
          'legal',
          'dist',
          environment.outputPrefix,
          locale,
          'index.html',
        ]),
        _fillTemplate(redirectTemplate, <String, String>{
          'target_url': localeIndexTarget,
        }),
      );
    }

    for (final MapEntry<String, String> alias in _localeAliases.entries) {
      _buildAliasLocale(
        repoRoot: repoRoot,
        environment: environment,
        alias: alias.key,
        canonicalLocale: alias.value,
        redirectTemplate: redirectTemplate,
      );
    }

    _writeFile(
      _join(repoRoot.path, <String>[
        'legal',
        'dist',
        environment.outputPrefix,
        'index.html',
      ]),
      _fillTemplate(redirectTemplate, <String, String>{
        'target_url': './en-US/${_documents.first}/',
      }),
    );

    stdout.writeln('Built legal site for ${environment.name}.');
  }
}

String? _readVersionOverride() {
  final String? raw = Platform.environment['LEGAL_SITE_VERSION'];
  if (raw == null) {
    return null;
  }
  final String trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

Map<String, String> _applyVersionOverride(
  Map<String, String> config,
  String? versionOverride,
) {
  if (versionOverride == null) {
    return config;
  }
  return <String, String>{...config, 'version': versionOverride};
}

void _buildCanonicalLocale({
  required Directory repoRoot,
  required _BuildEnvironment environment,
  required String locale,
  required Map<String, String> config,
  required String pageTemplate,
  required String requestPageTemplate,
  required String confirmPageTemplate,
}) {
  final Map<String, String> localeTitles = _titles[locale]!;
  final Map<String, String> localizedConfig = <String, String>{
    ...config,
    'deletion_request_url': _resolveLocaleDeletionRequestUrl(config, locale),
  };

  for (final String document in _documents) {
    final File contentFile = File(
      _join(repoRoot.path, <String>[
        'legal',
        'content',
        locale,
        '$document.md',
      ]),
    );

    if (!contentFile.existsSync()) {
      throw StateError('Missing legal content file: ${contentFile.path}');
    }

    final String markdown = _replaceTokens(
      contentFile.readAsStringSync(),
      localizedConfig,
    );

    final String pageHtml = _fillTemplate(pageTemplate, <String, String>{
      'lang_attr': locale.startsWith('de') ? 'de' : 'en',
      'page_title': localeTitles[document] ?? document,
      'site_name': config['site_name'] ?? 'Memuno',
      'locale': locale,
      'version': config['version'] ?? '0.0.0',
      'effective_date': config['effective_date'] ?? '',
      'support_email': config['support_email'] ?? '',
      'support_phone': config['support_phone'] ?? '',
      'privacy_contact_email': config['privacy_contact_email'] ?? '',
      'legal_entity': config['legal_entity'] ?? '',
      'legal_address': config['legal_address'] ?? '',
      'deletion_request_url': localizedConfig['deletion_request_url'] ?? '',
      'nav_links': _buildNavLinks(locale, localeTitles),
      'content_html': _markdownToHtml(markdown),
    });

    _writeFile(
      _join(repoRoot.path, <String>[
        'legal',
        'dist',
        environment.outputPrefix,
        locale,
        document,
        'index.html',
      ]),
      pageHtml,
    );
  }

  _buildAuxiliaryDeletionPages(
    repoRoot: repoRoot,
    environment: environment,
    locale: locale,
    config: config,
    requestPageTemplate: requestPageTemplate,
    confirmPageTemplate: confirmPageTemplate,
  );
}

String _resolveLocaleDeletionRequestUrl(
  Map<String, String> config,
  String locale,
) {
  final String siteUrl = _normalizeBaseUrl(
    _requiredConfigValue(config, 'site_url'),
  );
  return '$siteUrl/$locale/account-deletion-request/';
}

void _buildAliasLocale({
  required Directory repoRoot,
  required _BuildEnvironment environment,
  required String alias,
  required String canonicalLocale,
  required String redirectTemplate,
}) {
  for (final String page in _aliasRedirectPages) {
    _writeFile(
      _join(repoRoot.path, <String>[
        'legal',
        'dist',
        environment.outputPrefix,
        alias,
        page,
        'index.html',
      ]),
      _fillTemplate(redirectTemplate, <String, String>{
        'target_url': '../../$canonicalLocale/$page/',
      }),
    );
  }

  _writeFile(
    _join(repoRoot.path, <String>[
      'legal',
      'dist',
      environment.outputPrefix,
      alias,
      'index.html',
    ]),
    _fillTemplate(redirectTemplate, <String, String>{
      'target_url': '../$canonicalLocale/${_documents.first}/',
    }),
  );
}

void _buildAuxiliaryDeletionPages({
  required Directory repoRoot,
  required _BuildEnvironment environment,
  required String locale,
  required Map<String, String> config,
  required String requestPageTemplate,
  required String confirmPageTemplate,
}) {
  final String siteName = config['site_name'] ?? 'Memuno';
  final String siteUrl = _normalizeBaseUrl(
    _requiredConfigValue(config, 'site_url'),
  );
  final String supabaseUrl = _normalizeBaseUrl(
    _requiredConfigValue(config, 'supabase_url'),
  );
  final String supabasePublishableKey = _requiredConfigValue(
    config,
    'supabase_publishable_key',
  );
  final String accountDeletionDocUrl = '$siteUrl/$locale/account-deletion/';
  final String requestEndpointUrl =
      '$supabaseUrl/functions/v1/request-account-deletion-link';
  final String deleteEndpointUrl =
      '$supabaseUrl/functions/v1/delete-own-account';
  final Map<String, String> requestText = _requestPageText[locale]!;
  final Map<String, String> confirmText = _confirmPageText[locale]!;
  final String langAttr = locale.startsWith('de') ? 'de' : 'en';

  final String requestHtml =
      _fillTemplate(requestPageTemplate, <String, String>{
        'lang_attr': langAttr,
        'page_title': _escapeHtml(requestText['page_title']!),
        'site_name': _escapeHtml(siteName),
        'intro': _escapeHtml(requestText['intro']!),
        'email_label': _escapeHtml(requestText['email_label']!),
        'email_placeholder': _escapeHtml(requestText['email_placeholder']!),
        'submit_label': _escapeHtml(requestText['submit_label']!),
        'sending_label': _escapeHtml(requestText['sending_label']!),
        'success_message': _escapeHtml(requestText['success_message']!),
        'error_message': _escapeHtml(requestText['error_message']!),
        'back_link_label': _escapeHtml(requestText['back_link_label']!),
        'account_deletion_doc_url': _escapeHtml(accountDeletionDocUrl),
        'request_endpoint_url_json': jsonEncode(requestEndpointUrl),
        'locale_json': jsonEncode(locale),
      });

  _writeFile(
    _join(repoRoot.path, <String>[
      'legal',
      'dist',
      environment.outputPrefix,
      locale,
      'account-deletion-request',
      'index.html',
    ]),
    requestHtml,
  );

  final String confirmHtml =
      _fillTemplate(confirmPageTemplate, <String, String>{
        'lang_attr': langAttr,
        'page_title': _escapeHtml(confirmText['page_title']!),
        'site_name': _escapeHtml(siteName),
        'intro': _escapeHtml(confirmText['intro']!),
        'delete_button_label': _escapeHtml(confirmText['delete_button_label']!),
        'delete_button_label_json': jsonEncode(
          confirmText['delete_button_label']!,
        ),
        'back_link_label': _escapeHtml(confirmText['back_link_label']!),
        'account_deletion_doc_url': _escapeHtml(accountDeletionDocUrl),
        'supabase_url_json': jsonEncode(supabaseUrl),
        'supabase_publishable_key_json': jsonEncode(supabasePublishableKey),
        'delete_endpoint_url_json': jsonEncode(deleteEndpointUrl),
        'loading_message_json': jsonEncode(confirmText['loading_message']!),
        'ready_message_json': jsonEncode(confirmText['ready_message']!),
        'not_verified_message_json': jsonEncode(
          confirmText['not_verified_message']!,
        ),
        'verify_failed_message_json': jsonEncode(
          confirmText['verify_failed_message']!,
        ),
        'deleting_label_json': jsonEncode(confirmText['deleting_label']!),
        'deleted_message_json': jsonEncode(confirmText['deleted_message']!),
        'delete_failed_message_json': jsonEncode(
          confirmText['delete_failed_message']!,
        ),
      });

  _writeFile(
    _join(repoRoot.path, <String>[
      'legal',
      'dist',
      environment.outputPrefix,
      locale,
      'account-deletion-confirm',
      'index.html',
    ]),
    confirmHtml,
  );
}

String _requiredConfigValue(Map<String, String> config, String key) {
  final String value = config[key]?.trim() ?? '';
  if (value.isEmpty) {
    throw StateError('Missing required config value "$key".');
  }
  return value;
}

String _normalizeBaseUrl(String value) {
  final String normalized = value.trim().replaceAll(RegExp(r'/+$'), '');
  if (normalized.isEmpty) {
    throw StateError('Base URL value must not be empty.');
  }
  return normalized;
}

Map<String, String> _readConfig(String path) {
  final Object? raw = jsonDecode(File(path).readAsStringSync());
  if (raw is! Map<String, Object?>) {
    throw StateError('Invalid config JSON at $path');
  }

  return raw.map(
    (String key, Object? value) => MapEntry(key, value?.toString() ?? ''),
  );
}

String _replaceTokens(String value, Map<String, String> variables) {
  String output = value;
  for (final MapEntry<String, String> entry in variables.entries) {
    output = output.replaceAll('{{${entry.key}}}', entry.value);
  }
  return output;
}

String _buildNavLinks(String locale, Map<String, String> localeTitles) {
  return _documents
      .map(
        (String document) =>
            '<a href="../$document/">${_escapeHtml(localeTitles[document] ?? document)}</a>',
      )
      .join('\n          ');
}

String _fillTemplate(String template, Map<String, String> variables) {
  String output = template;
  for (final MapEntry<String, String> entry in variables.entries) {
    output = output.replaceAll('{{${entry.key}}}', entry.value);
  }
  return output;
}

String _markdownToHtml(String markdown) {
  final List<String> lines = markdown.split('\n');
  final StringBuffer buffer = StringBuffer();
  bool inUnorderedList = false;
  bool inOrderedList = false;

  void closeLists() {
    if (inUnorderedList) {
      buffer.writeln('</ul>');
      inUnorderedList = false;
    }
    if (inOrderedList) {
      buffer.writeln('</ol>');
      inOrderedList = false;
    }
  }

  for (final String originalLine in lines) {
    final String line = originalLine.trimRight();
    final String trimmed = line.trim();

    if (trimmed.isEmpty) {
      closeLists();
      continue;
    }

    if (trimmed.startsWith('# ')) {
      closeLists();
      buffer.writeln('<h2>${_escapeHtml(trimmed.substring(2).trim())}</h2>');
      continue;
    }

    if (trimmed.startsWith('## ')) {
      closeLists();
      buffer.writeln('<h3>${_escapeHtml(trimmed.substring(3).trim())}</h3>');
      continue;
    }

    if (trimmed.startsWith('### ')) {
      closeLists();
      buffer.writeln('<h4>${_escapeHtml(trimmed.substring(4).trim())}</h4>');
      continue;
    }

    if (trimmed.startsWith('- ')) {
      if (inOrderedList) {
        buffer.writeln('</ol>');
        inOrderedList = false;
      }
      if (!inUnorderedList) {
        buffer.writeln('<ul>');
        inUnorderedList = true;
      }
      buffer.writeln('<li>${_escapeHtml(trimmed.substring(2).trim())}</li>');
      continue;
    }

    final RegExpMatch? orderedMatch = RegExp(
      r'^\d+\.\s+(.*)$',
    ).firstMatch(trimmed);
    if (orderedMatch != null) {
      if (inUnorderedList) {
        buffer.writeln('</ul>');
        inUnorderedList = false;
      }
      if (!inOrderedList) {
        buffer.writeln('<ol>');
        inOrderedList = true;
      }
      buffer.writeln('<li>${_escapeHtml(orderedMatch.group(1) ?? '')}</li>');
      continue;
    }

    closeLists();
    final String escaped = _escapeHtml(trimmed);
    final String linked = escaped.replaceAllMapped(
      RegExp(r'(https?://[^\s<]+)'),
      (Match match) {
        final String url = match.group(1)!;
        return '<a href="$url">$url</a>';
      },
    );
    buffer.writeln('<p>$linked</p>');
  }

  closeLists();
  return buffer.toString().trim();
}

String _escapeHtml(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}

void _writeFile(String path, String contents) {
  final File file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync('$contents\n');
}

String _join(String first, List<String> parts) {
  final String separator = Platform.pathSeparator;
  final String rest = parts.join(separator);
  if (first.endsWith(separator)) {
    return '$first$rest';
  }
  return '$first$separator$rest';
}
