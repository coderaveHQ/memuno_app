import 'package:memuno_app/l10n/app_localizations.dart';

/// Report reasons stored in `public.ugc_reports.reason`.
enum UgcReportReason {
  spam('spam'),
  harassment('harassment'),
  hateSpeech('hate_speech'),
  sexualContent('sexual_content'),
  violence('violence'),
  scam('scam'),
  other('other');

  const UgcReportReason(this.databaseValue);

  /// Raw enum value persisted in Postgres.
  final String databaseValue;

  /// Parses one database enum label into [UgcReportReason].
  static UgcReportReason fromDatabaseValue(String value) {
    return switch (value) {
      'spam' => UgcReportReason.spam,
      'harassment' => UgcReportReason.harassment,
      'hate_speech' => UgcReportReason.hateSpeech,
      'sexual_content' => UgcReportReason.sexualContent,
      'violence' => UgcReportReason.violence,
      'scam' => UgcReportReason.scam,
      'other' => UgcReportReason.other,
      _ => throw FormatException('Unknown ugc_report_reason value: $value'),
    };
  }

  /// Localized label shown in report-reason selection UI.
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      UgcReportReason.spam => l10n.moderationReportReasonSpam,
      UgcReportReason.harassment => l10n.moderationReportReasonHarassment,
      UgcReportReason.hateSpeech => l10n.moderationReportReasonHateSpeech,
      UgcReportReason.sexualContent => l10n.moderationReportReasonSexualContent,
      UgcReportReason.violence => l10n.moderationReportReasonViolence,
      UgcReportReason.scam => l10n.moderationReportReasonScam,
      UgcReportReason.other => l10n.moderationReportReasonOther,
    };
  }
}
