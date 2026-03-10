import 'package:memuno_app/src/features/user_details/data/dto/user_details_dto.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';

/// Maps [UserDetailsDto] values into [UserDetailsEntity] values.
final class UserDetailsMapper {
  /// Creates a mapper.
  const UserDetailsMapper();

  /// Maps a DTO to the domain entity.
  UserDetailsEntity toDomain(UserDetailsDto dto) {
    return UserDetailsEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
