/// Converts [value] into short localized relative-time text.
String shortRelativeTimeText({
  /// Timestamp that should be formatted.
  required DateTime value,

  /// Localized label for "just now".
  required String justNowText,

  /// Localized formatter for "{count} minutes ago".
  required String Function(int count) minutesAgoText,

  /// Localized formatter for "{count} hours ago".
  required String Function(int count) hoursAgoText,

  /// Localized formatter for "{count} days ago".
  required String Function(int count) daysAgoText,

  /// Localized formatter for "{count} weeks ago".
  required String Function(int count) weeksAgoText,

  /// Localized formatter for "{count} months ago".
  required String Function(int count) monthsAgoText,

  /// Localized formatter for "{count} years ago".
  required String Function(int count) yearsAgoText,

  /// Optional "now" override for deterministic tests.
  DateTime? now,
}) {
  final DateTime reference = now ?? DateTime.now();
  final Duration difference = reference.difference(value.toLocal());

  if (difference.isNegative || difference.inSeconds < 45) {
    return justNowText;
  }

  if (difference.inMinutes < 60) {
    return minutesAgoText(difference.inMinutes);
  }

  if (difference.inHours < 24) {
    return hoursAgoText(difference.inHours);
  }

  if (difference.inDays < 7) {
    return daysAgoText(difference.inDays);
  }

  if (difference.inDays < 30) {
    return weeksAgoText(difference.inDays ~/ 7);
  }

  if (difference.inDays < 365) {
    return monthsAgoText(difference.inDays ~/ 30);
  }

  return yearsAgoText(difference.inDays ~/ 365);
}
