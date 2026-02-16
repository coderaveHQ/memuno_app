import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/core/failures/supabase_failure.dart';

part 'failure.freezed.dart';
part 'failure.g.dart';

/// Domain-level failure wrapper used across the app.
///
/// This is the primary error type consumed by the UI layer.
@freezed
sealed class Failure with _$Failure implements Exception {
  /// Wraps failures coming from Supabase or other backend sources.
  const factory Failure.supabase({required SupabaseFailure failure}) =
      SupabaseFailureWrapper;

  /// Represents a local input validation failure.
  const factory Failure.validation({
    /// Stable machine-readable code (e.g. `invalid_email`).
    required String code,

    /// Optional field name that caused the failure.
    String? field,

    /// Optional parameters for formatting messages.
    Map<String, Object?>? params,
  }) = ValidationFailureWrapper;

  /// Represents an offline or connectivity-related failure.
  const factory Failure.network({String? message}) = NetworkFailureWrapper;

  /// Represents an unknown or unclassified failure.
  const factory Failure.unknown({
    /// Optional raw message describing the failure.
    String? message,
  }) = UnknownFailureWrapper;

  /// Builds a [Failure] instance from JSON.
  factory Failure.fromJson(Map<String, Object?> json) =>
      _$FailureFromJson(json);
}
