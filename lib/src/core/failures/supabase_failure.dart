import 'package:freezed_annotation/freezed_annotation.dart';

part 'supabase_failure.freezed.dart';
part 'supabase_failure.g.dart';

/// Supabase-specific failure variants.
///
/// These map to Auth, Storage, Database/PostgREST, Postgres, and Functions
/// error payloads.
@freezed
sealed class SupabaseFailure with _$SupabaseFailure {
  /// Auth-related failure (GoTrue / auth API).
  const factory SupabaseFailure.auth({
    /// Auth error code from Supabase.
    String? code,

    /// Human-readable error message.
    String? message,

    /// HTTP status code as string (when available).
    String? statusCode,

    /// Optional list of reasons (e.g. weak password reasons).
    List<String>? reasons,

    /// Additional error metadata.
    Map<String, Object?>? metadata,
  }) = SupabaseAuthFailure;

  /// Storage-related failure.
  const factory SupabaseFailure.storage({
    /// Storage error code from Supabase.
    String? code,

    /// Human-readable error message.
    String? message,

    /// HTTP status code as string (when available).
    String? statusCode,

    /// Additional error metadata.
    Map<String, Object?>? metadata,
  }) = SupabaseStorageFailure;

  /// Database/API (PostgREST) related failure.
  const factory SupabaseFailure.database({
    /// Error code, typically PGRST or SQLSTATE depending on source.
    String? code,

    /// Human-readable error message.
    String? message,

    /// Optional details payload.
    Object? details,

    /// Optional hint for debugging.
    String? hint,

    /// HTTP status code (when available).
    int? statusCode,

    /// Additional error metadata.
    Map<String, Object?>? metadata,
  }) = SupabaseDatabaseFailure;

  /// Raw Postgres failure (SQLSTATE codes).
  const factory SupabaseFailure.postgres({
    /// SQLSTATE code.
    String? code,

    /// Human-readable error message.
    String? message,

    /// Optional details payload.
    Object? details,

    /// Optional hint for debugging.
    String? hint,

    /// Additional error metadata.
    Map<String, Object?>? metadata,
  }) = SupabasePostgresFailure;

  /// Edge Functions failure.
  const factory SupabaseFailure.functions({
    /// Custom function error code.
    String? code,

    /// User-facing error message (if provided by function).
    String? message,

    /// HTTP status code from function invoke.
    int? statusCode,

    /// Raw details payload.
    Object? details,

    /// Additional error metadata.
    Map<String, Object?>? metadata,
  }) = SupabaseFunctionsFailure;

  /// Unknown or unclassified Supabase failure.
  const factory SupabaseFailure.unknown({
    /// Optional raw error message.
    String? message,

    /// Additional error metadata.
    Map<String, Object?>? metadata,
  }) = SupabaseUnknownFailure;

  /// Builds a [SupabaseFailure] instance from JSON.
  factory SupabaseFailure.fromJson(Map<String, Object?> json) =>
      _$SupabaseFailureFromJson(json);
}
