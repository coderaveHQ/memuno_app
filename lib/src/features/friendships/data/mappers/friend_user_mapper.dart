import 'package:memuno_app/src/features/friendships/data/dto/friend_user_dto.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friend_user_entity.dart';

/// Maps [FriendUserDto] values into [FriendUserEntity] values.
final class FriendUserMapper {
  /// Creates a mapper.
  const FriendUserMapper();

  /// Maps a friend user DTO to the domain entity.
  FriendUserEntity toDomain(FriendUserDto dto) {
    return FriendUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
    );
  }
}
