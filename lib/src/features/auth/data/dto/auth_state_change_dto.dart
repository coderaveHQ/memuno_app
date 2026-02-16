import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/auth/data/dto/auth_user_dto.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';

part 'auth_state_change_dto.freezed.dart';
part 'auth_state_change_dto.g.dart';

/// DTO representing an auth state change emitted by Supabase.
///
/// This DTO mirrors Supabase events and is mapped into a domain entity.
@freezed
sealed class AuthStateChangeDto with _$AuthStateChangeDto {
  /// Creates an auth state change DTO.
  const factory AuthStateChangeDto({
    /// Auth lifecycle event from Supabase.
    required AuthEvent event,

    /// Current user, if any.
    AuthUserDto? user,
  }) = _AuthStateChangeDto;

  /// Builds a DTO from JSON.
  factory AuthStateChangeDto.fromJson(Map<String, Object?> json) =>
      _$AuthStateChangeDtoFromJson(json);
}
