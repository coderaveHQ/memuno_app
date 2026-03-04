import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_user_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_user_entity.dart';

/// Maps friendship nested-user DTOs into domain entities.
final class FriendUserMapper {
  /// Creates a mapper.
  const FriendUserMapper();

  /// Maps a friendship-list user DTO to a domain entity.
  FriendshipListPageItemUserEntity toFriendshipListPageItemUserDomain(
    FriendshipListPageItemUserDto dto,
  ) {
    return FriendshipListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps a friendship-request-list user DTO to a domain entity.
  FriendshipRequestListPageItemUserEntity
  toFriendshipRequestListPageItemUserDomain(
    FriendshipRequestListPageItemUserDto dto,
  ) {
    return FriendshipRequestListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
