import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:memuno_app/src/app/router/app_router.dart';

/// Defines how the date portion should be rendered for non-relative output.
enum DatePortionStyle {
  /// Uses a compact numeric representation such as `17.02.2026` or `2/17/2026`.
  numeric,

  /// Uses a full textual representation such as `Tuesday, February 17, 2026`.
  full,
}

/// Immutable configuration object that controls locale-aware `DateTime` formatting.
///
/// This object centralizes all formatting knobs so callers can explicitly choose
/// whether they want date-only output, date-time output, second precision, or
/// human-readable relative text.
class LocalizedDateTimeFormatOptions {
  /// Creates a new formatting configuration with explicit output controls.
  const LocalizedDateTimeFormatOptions({
    this.convertToLocal = true,
    this.humanReadable = false,
    this.allowFutureText = true,
    this.includeDate = true,
    this.includeTime = true,
    this.includeSeconds = false,
    this.dateStyle = DatePortionStyle.numeric,
    this.now,
  });

  /// When `true`, the target `DateTime` is converted with `toLocal()` first.
  ///
  /// This keeps user-facing output aligned with the device time zone.
  final bool convertToLocal;

  /// Enables relative-time output such as `just now` or `vor 2 Minuten`.
  ///
  /// When enabled, absolute date/time fields are ignored and relative output
  /// is returned instead.
  final bool humanReadable;

  /// Controls whether future relative phrases are allowed, e.g. `in 2 minutes`.
  ///
  /// If this is `false`, future values are rendered as absolute date-time text
  /// rather than a relative phrase.
  final bool allowFutureText;

  /// Controls whether the date portion is included in absolute formatting.
  final bool includeDate;

  /// Controls whether the time portion is included in absolute formatting.
  final bool includeTime;

  /// Controls second precision for absolute time output.
  ///
  /// If `false`, output is truncated to minute precision.
  final bool includeSeconds;

  /// Selects whether the date portion is numeric or full textual.
  final DatePortionStyle dateStyle;

  /// Optional reference time for deterministic relative formatting.
  ///
  /// If omitted, the formatter uses `DateTime.now()`.
  final DateTime? now;
}

/// Adds locale-aware absolute and relative formatting helpers to `DateTime`.
extension DateTimeExtension on DateTime {
  /// Formats this value using the active app locale and explicit output options.
  ///
  /// Behavior summary:
  /// - Relative output if `options.humanReadable == true`.
  /// - Absolute output otherwise with fine-grained `includeDate/includeTime`.
  /// - Throws `ArgumentError` when both `includeDate` and `includeTime` are `false`.
  String formatLocalized({
    LocalizedDateTimeFormatOptions options =
        const LocalizedDateTimeFormatOptions(),
  }) {
    final String resolvedLocale = _resolveAppLocale();
    final String languageCode = _extractLanguageCode(resolvedLocale);
    final DateTime value = options.convertToLocal ? toLocal() : this;

    if (options.humanReadable) {
      final DateTime referenceNow;
      if (options.now != null) {
        referenceNow = options.convertToLocal
            ? options.now!.toLocal()
            : options.now!;
      } else {
        referenceNow = DateTime.now();
      }

      return _formatRelative(
        value: value,
        reference: referenceNow,
        locale: resolvedLocale,
        languageCode: languageCode,
        allowFutureText: options.allowFutureText,
      );
    }

    if (!options.includeDate && !options.includeTime) {
      throw ArgumentError(
        'At least one of includeDate or includeTime must be true when '
        'humanReadable is false.',
      );
    }

    final DateFormat formatter = _buildAbsoluteFormatter(
      locale: resolvedLocale,
      options: options,
    );
    return formatter.format(value);
  }

  /// Formats this value as date-only output according to the active app locale.
  ///
  /// Set `fullDate` to `true` for a textual date (weekday + month name), or
  /// leave it `false` for a compact numeric date.
  String formatDateOnly({bool convertToLocal = true, bool fullDate = false}) {
    return formatLocalized(
      options: LocalizedDateTimeFormatOptions(
        convertToLocal: convertToLocal,
        includeDate: true,
        includeTime: false,
        dateStyle: fullDate ? DatePortionStyle.full : DatePortionStyle.numeric,
      ),
    );
  }

  /// Formats this value as date + time according to locale conventions.
  ///
  /// Set `fullDate` to `true` for a textual date portion and `includeSeconds`
  /// to `true` when second precision is required.
  String formatDateWithTime({
    bool convertToLocal = true,
    bool includeSeconds = false,
    bool fullDate = false,
  }) {
    return formatLocalized(
      options: LocalizedDateTimeFormatOptions(
        convertToLocal: convertToLocal,
        includeDate: true,
        includeTime: true,
        includeSeconds: includeSeconds,
        dateStyle: fullDate ? DatePortionStyle.full : DatePortionStyle.numeric,
      ),
    );
  }

  /// Formats this value as full textual date + time up to the minute.
  ///
  /// This helper is intended for output like "Tuesday, February 17, 2026, 14:30"
  /// with locale-specific ordering and separators.
  String formatFullDateToMinute({bool convertToLocal = true}) {
    return formatLocalized(
      options: LocalizedDateTimeFormatOptions(
        convertToLocal: convertToLocal,
        includeDate: true,
        includeTime: true,
        includeSeconds: false,
        dateStyle: DatePortionStyle.full,
      ),
    );
  }

  /// Formats this value as localized relative text such as:
  /// - `just now`
  /// - `vor 2 Minuten`
  /// - `in 3 hours`
  ///
  /// Use `now` for deterministic tests and `allowFutureText` to decide whether
  /// future values should be expressed relatively.
  String formatHumanReadable({
    DateTime? now,
    bool convertToLocal = true,
    bool allowFutureText = true,
  }) {
    return formatLocalized(
      options: LocalizedDateTimeFormatOptions(
        convertToLocal: convertToLocal,
        humanReadable: true,
        allowFutureText: allowFutureText,
        now: now,
      ),
    );
  }

  /// Resolves the active app locale for `intl` formatters.
  ///
  /// Resolution order:
  /// 1) Current root-localizations context from the app navigator.
  /// 2) `Intl.getCurrentLocale()` as global intl fallback.
  /// 3) Platform dispatcher locale as final fallback.
  String _resolveAppLocale() {
    final BuildContext? context = rootNavigatorKey.currentContext;
    final Locale? appLocale = context == null
        ? null
        : Localizations.maybeLocaleOf(context);
    if (appLocale != null) {
      return Intl.canonicalizedLocale(appLocale.toString());
    }

    final String intlLocale = Intl.getCurrentLocale();
    if (intlLocale.trim().isNotEmpty) {
      return Intl.canonicalizedLocale(intlLocale);
    }

    final Locale fallbackLocale =
        WidgetsBinding.instance.platformDispatcher.locale;
    return Intl.canonicalizedLocale(fallbackLocale.toString());
  }

  /// Extracts the language code (`de`, `en`, ...) from a locale identifier.
  String _extractLanguageCode(String locale) {
    return locale.split(RegExp(r'[_-]')).first.toLowerCase();
  }

  /// Builds an absolute date/time formatter based on the provided options.
  DateFormat _buildAbsoluteFormatter({
    required String locale,
    required LocalizedDateTimeFormatOptions options,
  }) {
    if (options.includeDate && options.includeTime) {
      final DateFormat formatter = options.dateStyle == DatePortionStyle.full
          ? DateFormat.yMMMMEEEEd(locale)
          : DateFormat.yMd(locale);

      return options.includeSeconds ? formatter.add_jms() : formatter.add_jm();
    }

    if (options.includeDate) {
      return options.dateStyle == DatePortionStyle.full
          ? DateFormat.yMMMMEEEEd(locale)
          : DateFormat.yMd(locale);
    }

    return options.includeSeconds
        ? DateFormat.jms(locale)
        : DateFormat.jm(locale);
  }

  /// Converts this value into localized relative text.
  ///
  /// Internally this method maps the distance to a time unit bucket and then
  /// creates language-specific phrases for German (`de`) and English fallback.
  String _formatRelative({
    required DateTime value,
    required DateTime reference,
    required String locale,
    required String languageCode,
    required bool allowFutureText,
  }) {
    final Duration delta = reference.difference(value);
    final bool isPast = !delta.isNegative;
    final Duration absoluteDelta = delta.abs();

    if (absoluteDelta < const Duration(seconds: 45)) {
      return _relativeJustNow(languageCode);
    }

    if (!isPast && !allowFutureText) {
      return DateFormat.yMd(locale).add_jm().format(value);
    }

    final _RelativeTimeValue relativeValue = _toRelativeTimeValue(
      absoluteDelta,
    );

    if (isPast) {
      return _relativePast(
        languageCode: languageCode,
        unit: relativeValue.unit,
        value: relativeValue.value,
      );
    }

    return _relativeFuture(
      languageCode: languageCode,
      unit: relativeValue.unit,
      value: relativeValue.value,
    );
  }

  /// Maps an absolute duration to one relative unit/value pair.
  ///
  /// Example:
  /// - `72 minutes` -> `1 hour`
  /// - `10 days` -> `1 week`
  _RelativeTimeValue _toRelativeTimeValue(Duration absoluteDelta) {
    if (absoluteDelta < const Duration(minutes: 2)) {
      return const _RelativeTimeValue(unit: _RelativeUnit.minute, value: 1);
    }

    if (absoluteDelta < const Duration(minutes: 60)) {
      return _RelativeTimeValue(
        unit: _RelativeUnit.minute,
        value: absoluteDelta.inMinutes,
      );
    }

    if (absoluteDelta < const Duration(hours: 2)) {
      return const _RelativeTimeValue(unit: _RelativeUnit.hour, value: 1);
    }

    if (absoluteDelta < const Duration(hours: 24)) {
      return _RelativeTimeValue(
        unit: _RelativeUnit.hour,
        value: absoluteDelta.inHours,
      );
    }

    if (absoluteDelta < const Duration(days: 2)) {
      return const _RelativeTimeValue(unit: _RelativeUnit.day, value: 1);
    }

    if (absoluteDelta < const Duration(days: 7)) {
      return _RelativeTimeValue(
        unit: _RelativeUnit.day,
        value: absoluteDelta.inDays,
      );
    }

    if (absoluteDelta < const Duration(days: 30)) {
      return _RelativeTimeValue(
        unit: _RelativeUnit.week,
        value: (absoluteDelta.inDays / 7).floor(),
      );
    }

    if (absoluteDelta < const Duration(days: 365)) {
      return _RelativeTimeValue(
        unit: _RelativeUnit.month,
        value: (absoluteDelta.inDays / 30).floor(),
      );
    }

    return _RelativeTimeValue(
      unit: _RelativeUnit.year,
      value: (absoluteDelta.inDays / 365).floor(),
    );
  }

  /// Returns the localized equivalent of "just now".
  String _relativeJustNow(String languageCode) {
    switch (languageCode) {
      case 'de':
        return 'gerade eben';
      default:
        return 'just now';
    }
  }

  /// Formats a past relative phrase such as "vor 2 Stunden" / "2 hours ago".
  String _relativePast({
    required String languageCode,
    required _RelativeUnit unit,
    required int value,
  }) {
    switch (languageCode) {
      case 'de':
        return _relativePastDe(unit: unit, value: value);
      default:
        return _relativePastEn(unit: unit, value: value);
    }
  }

  /// Formats a future relative phrase such as "in 2 Stunden" / "in 2 hours".
  String _relativeFuture({
    required String languageCode,
    required _RelativeUnit unit,
    required int value,
  }) {
    switch (languageCode) {
      case 'de':
        return _relativeFutureDe(unit: unit, value: value);
      default:
        return _relativeFutureEn(unit: unit, value: value);
    }
  }

  /// Returns German past tense relative phrases.
  String _relativePastDe({required _RelativeUnit unit, required int value}) {
    switch (unit) {
      case _RelativeUnit.minute:
        return value == 1 ? 'vor 1 Minute' : 'vor $value Minuten';
      case _RelativeUnit.hour:
        return value == 1 ? 'vor 1 Stunde' : 'vor $value Stunden';
      case _RelativeUnit.day:
        return value == 1 ? 'vor 1 Tag' : 'vor $value Tagen';
      case _RelativeUnit.week:
        return value == 1 ? 'vor 1 Woche' : 'vor $value Wochen';
      case _RelativeUnit.month:
        return value == 1 ? 'vor 1 Monat' : 'vor $value Monaten';
      case _RelativeUnit.year:
        return value == 1 ? 'vor 1 Jahr' : 'vor $value Jahren';
    }
  }

  /// Returns German future tense relative phrases.
  String _relativeFutureDe({required _RelativeUnit unit, required int value}) {
    switch (unit) {
      case _RelativeUnit.minute:
        return value == 1 ? 'in 1 Minute' : 'in $value Minuten';
      case _RelativeUnit.hour:
        return value == 1 ? 'in 1 Stunde' : 'in $value Stunden';
      case _RelativeUnit.day:
        return value == 1 ? 'in 1 Tag' : 'in $value Tagen';
      case _RelativeUnit.week:
        return value == 1 ? 'in 1 Woche' : 'in $value Wochen';
      case _RelativeUnit.month:
        return value == 1 ? 'in 1 Monat' : 'in $value Monaten';
      case _RelativeUnit.year:
        return value == 1 ? 'in 1 Jahr' : 'in $value Jahren';
    }
  }

  /// Returns English past tense relative phrases.
  String _relativePastEn({required _RelativeUnit unit, required int value}) {
    switch (unit) {
      case _RelativeUnit.minute:
        return value == 1 ? '1 minute ago' : '$value minutes ago';
      case _RelativeUnit.hour:
        return value == 1 ? '1 hour ago' : '$value hours ago';
      case _RelativeUnit.day:
        return value == 1 ? '1 day ago' : '$value days ago';
      case _RelativeUnit.week:
        return value == 1 ? '1 week ago' : '$value weeks ago';
      case _RelativeUnit.month:
        return value == 1 ? '1 month ago' : '$value months ago';
      case _RelativeUnit.year:
        return value == 1 ? '1 year ago' : '$value years ago';
    }
  }

  /// Returns English future tense relative phrases.
  String _relativeFutureEn({required _RelativeUnit unit, required int value}) {
    switch (unit) {
      case _RelativeUnit.minute:
        return value == 1 ? 'in 1 minute' : 'in $value minutes';
      case _RelativeUnit.hour:
        return value == 1 ? 'in 1 hour' : 'in $value hours';
      case _RelativeUnit.day:
        return value == 1 ? 'in 1 day' : 'in $value days';
      case _RelativeUnit.week:
        return value == 1 ? 'in 1 week' : 'in $value weeks';
      case _RelativeUnit.month:
        return value == 1 ? 'in 1 month' : 'in $value months';
      case _RelativeUnit.year:
        return value == 1 ? 'in 1 year' : 'in $value years';
    }
  }
}

/// Internal unit enum used for relative-time phrase selection.
enum _RelativeUnit {
  /// Minute-level relative unit.
  minute,

  /// Hour-level relative unit.
  hour,

  /// Day-level relative unit.
  day,

  /// Week-level relative unit.
  week,

  /// Month-level relative unit.
  month,

  /// Year-level relative unit.
  year,
}

/// Internal value object representing one relative quantity and its unit.
class _RelativeTimeValue {
  /// Creates a relative quantity payload.
  const _RelativeTimeValue({required this.unit, required this.value});

  /// Relative unit bucket (minute, hour, day, ...).
  final _RelativeUnit unit;

  /// Rounded integer value belonging to [unit].
  final int value;
}
