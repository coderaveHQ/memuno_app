import 'package:memuno_app/src/features/auth/data/dto/auth_user_dto.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_user_entity.dart';

/// Maps [AuthUserDto] to domain [AuthUserEntity].
final class AuthUserMapper {
  /// Creates a mapper.
  const AuthUserMapper();

  /// Maps a DTO into a domain entity.
  AuthUserEntity toDomain(AuthUserDto dto) {
    return AuthUserEntity(id: dto.id, email: dto.email);
  }
}
