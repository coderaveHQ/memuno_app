import 'package:flutter/widgets.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/failures/supabase_failure.dart';

/// Resolves user-facing messages for [Failure] values.
final class FailureMessageResolver {
  /// Creates a message resolver for [Failure] values.
  const FailureMessageResolver();

  /// Resolves a [Failure] into a localized message.
  String resolve(BuildContext context, Failure failure) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return failure.when(
      supabase: (SupabaseFailure failure) => _resolveSupabase(l10n, failure),
      validation: (String code, String? field, Map<String, Object?>? params) =>
          _resolveValidation(l10n, code, params),
      network: (String? message) =>
          _withFallback(message, l10n.networkErrorMessage),
      unknown: (String? message) =>
          _withFallback(message, l10n.genericErrorMessage),
    );
  }

  /// Returns resolve supabase.
  String _resolveSupabase(AppLocalizations l10n, SupabaseFailure failure) {
    return failure.when(
      auth:
          (
            String? code,
            String? message,
            String? statusCode,
            List<String>? reasons,
            Map<String, Object?>? metadata,
          ) => _withFallback(message, l10n.serverErrorMessage),
      storage:
          (
            String? code,
            String? message,
            String? statusCode,
            Map<String, Object?>? metadata,
          ) => _withFallback(message, l10n.serverErrorMessage),
      database:
          (
            String? code,
            String? message,
            Object? details,
            String? hint,
            int? statusCode,
            Map<String, Object?>? metadata,
          ) => _withFallback(message, l10n.serverErrorMessage),
      postgres:
          (
            String? code,
            String? message,
            Object? details,
            String? hint,
            Map<String, Object?>? metadata,
          ) => _withFallback(message, l10n.serverErrorMessage),
      functions:
          (
            String? code,
            String? message,
            int? statusCode,
            Object? details,
            Map<String, Object?>? metadata,
          ) => _withFallback(message, l10n.serverErrorMessage),
      unknown: (String? message, Map<String, Object?>? metadata) =>
          _withFallback(message, l10n.serverErrorMessage),
    );
  }

  /// Returns resolve validation.
  String _resolveValidation(
    AppLocalizations l10n,
    String code,
    Map<String, Object?>? params,
  ) {
    return switch (code) {
      'invalid_email' => l10n.validationInvalidEmail,
      'invalid_format' => l10n.validationInvalidFormat,
      'invalid_friendship_code' => l10n.validationInvalidFriendshipCode,
      'min_length' => _withMinLength(l10n, params),
      'max_length' => _withMaxLength(l10n, params),
      'invalid_credentials' => l10n.validationInvalidCredentials,
      _ => l10n.validationUnknown,
    };
  }

  /// Returns with min length.
  String _withMinLength(AppLocalizations l10n, Map<String, Object?>? params) {
    final Object? min = params?['min'];
    if (min == null) {
      return l10n.validationUnknown;
    }
    return l10n.validationMinLength(min);
  }

  /// Returns with max length.
  String _withMaxLength(AppLocalizations l10n, Map<String, Object?>? params) {
    final Object? max = params?['max'];
    if (max == null) {
      return l10n.validationUnknown;
    }
    return l10n.validationMaxLength(max);
  }

  /// Returns with fallback.
  String _withFallback(String? message, String fallback) {
    if (message != null && message.isNotEmpty) {
      return message;
    }
    return fallback;
  }
}
