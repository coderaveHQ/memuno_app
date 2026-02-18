import 'package:memuno_app/src/features/friendships/data/dto/friendship_dto.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friend_user_mapper.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_entity.dart';

/// Maps [FriendshipDto] values into [FriendshipEntity] values.
final class FriendshipMapper {
  /// Creates a mapper.
  const FriendshipMapper({required FriendUserMapper friendUserMapper})
    : _friendUserMapper = friendUserMapper;

  /// Mapper used for nested friend-user payloads.
  final FriendUserMapper _friendUserMapper;

  /// Maps a friendship DTO to the domain entity.
  FriendshipEntity toDomain(FriendshipDto dto) {
    return FriendshipEntity(
      user: _friendUserMapper.toDomain(dto.user),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
