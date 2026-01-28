import 'package:flutter/foundation.dart';

/// Minimal app logger.
///
/// Goals:
/// - Provide a single, tiny abstraction for structured logs.
/// - Keep call sites stable even if we later swap the implementation.
/// - Avoid heavy dependencies until we truly need them.
///
/// Important:
/// - Logging stays in English (developer-facing).
/// - We do **not** print in release builds to keep production output clean.
/// - This logger is intentionally simple; higher-level logging can be layered
///   on top (e.g. Crashlytics breadcrumbs, Supabase log shipping, etc.).
final class Logger {
  /// Private constructor to enforce a singleton-style usage.
  Logger._();

  /// Global singleton instance.
  ///
  /// Note:
  /// We keep this for now because it is lightweight and easy to use.
  /// In the app architecture we still expose this via a Riverpod provider so
  /// everything remains testable and replaceable.
  static final Logger instance = Logger._();

  /// Writes an informational log line.
  void info({required String message}) {
    _log(level: 'INFO', message: message);
  }

  /// Writes a warning log line.
  ///
  /// Use for recoverable issues (e.g. retryable network errors).
  void warn({required String message, Object? error, StackTrace? stackTrace}) {
    _log(level: 'WARN', message: message, error: error, stackTrace: stackTrace);
  }

  /// Writes an error log line.
  ///
  /// Use for unexpected failures that should be investigated.
  void error({required String message, Object? error, StackTrace? stackTrace}) {
    _log(
      level: 'ERROR',
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Internal log formatter + output.
  ///
  /// Output policy:
  /// - Debug only: print to console for local development.
  /// - Release: stay quiet by default. If needed, this can later forward logs
  ///   to Crashlytics or a backend endpoint.
  void _log({
    required String level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) {
      // In production, keep console output minimal.
      // Forwarding to Crashlytics / backend can be implemented later if desired.
      return;
    }

    // Base message format: "[LEVEL] message"
    final String base = '[$level] $message';

    // Fast path: plain message only.
    if (error == null && stackTrace == null) {
      // ignore: avoid_print
      print(base);
      return;
    }

    // Full output includes optional error and stack trace.
    // ignore: avoid_print
    print('$base\nerror=$error\nstack=$stackTrace');
  }
}
