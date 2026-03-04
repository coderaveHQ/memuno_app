import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_item_dto.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friend_user_mapper.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_direction.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_status.dart';

/// Maps friendship-request DTOs into domain entities.
final class FriendshipRequestMapper {
  /// Creates a mapper.
  const FriendshipRequestMapper({required FriendUserMapper friendUserMapper})
    : _friendUserMapper = friendUserMapper;

  /// Mapper used for nested friend-user payloads.
  final FriendUserMapper _friendUserMapper;

  /// Maps one friendship-request-list item DTO to the domain entity.
  FriendshipRequestListPageItemEntity toDomain(
    FriendshipRequestListPageItemDto dto,
  ) {
    return FriendshipRequestListPageItemEntity(
      id: dto.id,
      user: _friendUserMapper.toFriendshipRequestListPageItemUserDomain(
        dto.user,
      ),
      status: _toStatus(dto.status),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      direction: _toDirection(dto.direction),
    );
  }

  /// Maps one friendship-request-list page DTO to the domain entity.
  FriendshipRequestListPageEntity pageToDomain(
    FriendshipRequestListPageDto dto,
  ) {
    return FriendshipRequestListPageEntity(
      items: dto.items.map(toDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  /// Converts raw status string values into domain enum values.
  FriendshipRequestStatus _toStatus(String rawStatus) {
    return switch (rawStatus) {
      'pending' => FriendshipRequestStatus.pending,
      'accepted' => FriendshipRequestStatus.accepted,
      'declined' => FriendshipRequestStatus.declined,
      'canceled' => FriendshipRequestStatus.canceled,
      _ => throw FormatException(
        'Unknown friendship request status value: $rawStatus',
      ),
    };
  }

  /// Converts raw direction string values into domain enum values.
  FriendshipRequestDirection _toDirection(String rawDirection) {
    return switch (rawDirection) {
      'incoming' => FriendshipRequestDirection.incoming,
      'outgoing' => FriendshipRequestDirection.outgoing,
      _ => throw FormatException(
        'Unknown friendship request direction value: $rawDirection',
      ),
    };
  }
}
