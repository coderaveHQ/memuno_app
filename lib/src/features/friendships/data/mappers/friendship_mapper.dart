import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_item_dto.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friend_user_mapper.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';

/// Maps friendship DTOs into domain entities.
final class FriendshipMapper {
  /// Creates a mapper.
  const FriendshipMapper({required FriendUserMapper friendUserMapper})
    : _friendUserMapper = friendUserMapper;

  /// Mapper used for nested friend-user payloads.
  final FriendUserMapper _friendUserMapper;

  /// Maps one friendship-list item DTO to the domain entity.
  FriendshipListPageItemEntity toDomain(FriendshipListPageItemDto dto) {
    return FriendshipListPageItemEntity(
      user: _friendUserMapper.toFriendshipListPageItemUserDomain(dto.user),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps one friendship-list page DTO to the domain entity.
  FriendshipListPageEntity pageToDomain(FriendshipListPageDto dto) {
    return FriendshipListPageEntity(
      items: dto.items.map(toDomain).toList(growable: false),
      nextCursorName: dto.nextCursorName,
      nextCursorId: dto.nextCursorId,
    );
  }
}
