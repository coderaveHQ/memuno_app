import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_user_dto.freezed.dart';
part 'auth_user_dto.g.dart';

/// Data transfer object for Supabase auth users.
///
/// This DTO represents the raw data from Supabase and is mapped into
/// a domain [AuthUserEntity] by the mapper.
@freezed
sealed class AuthUserDto with _$AuthUserDto {
  /// Creates an [AuthUserDto].
  const factory AuthUserDto({
    /// Unique user identifier from Supabase.
    required String id,

    /// Email address if available.
    String? email,
  }) = _AuthUserDto;

  /// Builds a DTO from Supabase [User].
  factory AuthUserDto.fromSupabase(User user) {
    return AuthUserDto(id: user.id, email: user.email);
  }

  /// Builds a DTO from JSON.
  factory AuthUserDto.fromJson(Map<String, Object?> json) =>
      _$AuthUserDtoFromJson(json);
}
