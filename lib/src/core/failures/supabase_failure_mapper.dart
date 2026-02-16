import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/failures/supabase_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps Supabase SDK exceptions into app [Failure] values.
final class SupabaseFailureMapper implements FailureMapper {
  /// Creates a Supabase failure mapper.
  const SupabaseFailureMapper();

  /// Maps an arbitrary [error] into a Supabase-related [Failure].
  @override
  Failure map(Object error) {
    if (error is supabase.AuthException) {
      return Failure.supabase(failure: _mapAuth(error));
    }
    if (error is supabase.StorageException) {
      return Failure.supabase(failure: _mapStorage(error));
    }
    if (error is supabase.PostgrestException) {
      return Failure.supabase(failure: _mapPostgrest(error));
    }
    if (error is supabase.FunctionException) {
      return Failure.supabase(failure: _mapFunctions(error));
    }

    return Failure.supabase(
      failure: SupabaseFailure.unknown(message: error.toString()),
    );
  }

  /// Maps Supabase auth errors to [SupabaseFailure.auth].
  SupabaseFailure _mapAuth(supabase.AuthException error) {
    if (error is supabase.AuthWeakPasswordException) {
      return SupabaseFailure.auth(
        code: error.code,
        message: error.message,
        statusCode: error.statusCode,
        reasons: error.reasons,
      );
    }

    return SupabaseFailure.auth(
      code: error.code,
      message: error.message,
      statusCode: error.statusCode,
    );
  }

  /// Maps Supabase storage errors to [SupabaseFailure.storage].
  SupabaseFailure _mapStorage(supabase.StorageException error) {
    return SupabaseFailure.storage(
      code: error.error,
      message: error.message,
      statusCode: error.statusCode,
    );
  }

  /// Maps PostgREST errors to database or Postgres failures.
  SupabaseFailure _mapPostgrest(supabase.PostgrestException error) {
    final String? code = error.code;
    if (_isSqlStateCode(code)) {
      return SupabaseFailure.postgres(
        code: code,
        message: error.message,
        details: error.details,
        hint: error.hint,
      );
    }

    return SupabaseFailure.database(
      code: code,
      message: error.message,
      details: error.details,
      hint: error.hint,
    );
  }

  /// Maps function invoke errors to [SupabaseFailure.functions].
  SupabaseFailure _mapFunctions(supabase.FunctionException error) {
    final FunctionErrorDetails details = _parseFunctionDetails(error.details);
    return SupabaseFailure.functions(
      code: details.code,
      message: details.message ?? error.reasonPhrase,
      statusCode: error.status,
      details: details.details ?? error.details,
      metadata: details.metadata,
    );
  }

  /// Checks if a code looks like a SQLSTATE identifier.
  bool _isSqlStateCode(String? code) {
    if (code == null || code.length != 5) {
      return false;
    }
    return RegExp(r'^[A-Z0-9]{5}$').hasMatch(code);
  }

  /// Parses structured function error payloads from [details].
  FunctionErrorDetails _parseFunctionDetails(Object? details) {
    if (details is Map) {
      final String? code =
          _stringValue(details['code']) ??
          _stringValue(details['errorCode']) ??
          _stringValue(details['error']);
      final String? message =
          _stringValue(details['userMessage']) ??
          _stringValue(details['message']);
      return FunctionErrorDetails(
        code: code,
        message: message,
        details: details['details'],
        metadata: _mapFromDynamic(details['meta']),
      );
    }

    return const FunctionErrorDetails();
  }

  /// Normalizes dynamic maps into `Map<String, Object?>`.
  Map<String, Object?>? _mapFromDynamic(Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, dynamic value) => MapEntry(key.toString(), value));
    }
    return null;
  }

  /// Converts an arbitrary value into a string, if possible.
  String? _stringValue(Object? value) {
    return value?.toString();
  }
}

/// Normalized error details returned by Edge Functions.
final class FunctionErrorDetails {
  /// Creates a normalized error detail object.
  const FunctionErrorDetails({
    this.code,
    this.message,
    this.details,
    this.metadata,
  });

  /// Optional error code returned by the function.
  final String? code;

  /// Optional user-facing message returned by the function.
  final String? message;

  /// Optional raw details payload from the function.
  final Object? details;

  /// Optional structured metadata for debugging/analytics.
  final Map<String, Object?>? metadata;
}
