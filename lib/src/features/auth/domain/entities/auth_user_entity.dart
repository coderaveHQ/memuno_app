import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_user_entity.freezed.dart';

/// Domain entity representing the authenticated user.
///
/// This entity is intentionally minimal and UI-agnostic so it can be reused
/// across features without leaking transport or presentation concerns.
@freezed
sealed class AuthUserEntity with _$AuthUserEntity {
  /// Creates an [AuthUserEntity] instance.
  const factory AuthUserEntity({
    /// Unique identifier for the authenticated user.
    required String id,

    /// Email address if available.
    String? email,
  }) = _AuthUserEntity;
}
