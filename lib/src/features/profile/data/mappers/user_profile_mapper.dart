import 'package:memuno_app/src/features/profile/data/dto/user_profile_dto.dart';
import 'package:memuno_app/src/features/profile/domain/entities/user_profile_entity.dart';

/// Maps [UserProfileDto] values into [UserProfileEntity] values.
final class UserProfileMapper {
  /// Creates a mapper.
  const UserProfileMapper();

  /// Maps a DTO to the domain entity.
  UserProfileEntity toDomain(UserProfileDto dto) {
    return UserProfileEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
