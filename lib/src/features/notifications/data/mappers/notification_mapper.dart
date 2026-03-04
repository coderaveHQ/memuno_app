import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_dto.dart';
import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_item_data_dto.dart';
import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_item_dto.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_data_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_entity.dart';

/// Maps notification DTOs into domain entities.
final class NotificationMapper {
  /// Creates a mapper.
  const NotificationMapper();

  /// Maps one notification-list item DTO to the domain entity.
  NotificationListPageItemEntity toDomain(NotificationListPageItemDto dto) {
    return NotificationListPageItemEntity(
      id: dto.id,
      type: dto.type,
      data: _mapData(dto.data),
      isRead: dto.isRead,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps one notification-list page DTO to the domain entity.
  NotificationListPageEntity pageToDomain(NotificationListPageDto dto) {
    return NotificationListPageEntity(
      items: dto.items.map(toDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  NotificationListPageItemDataEntity _mapData(
    NotificationListPageItemDataDto dto,
  ) {
    return switch (dto) {
      FriendshipRequestSentNotificationDataDto data =>
        NotificationListPageItemDataEntity.friendshipRequestSent(
          actorId: data.actorId,
          actorName: data.actorName,
          actorFriendshipCode: data.actorFriendshipCode,
          requestId: data.requestId,
          routeTab: data.routeTab,
        ),
      FriendshipRequestAcceptedNotificationDataDto data =>
        NotificationListPageItemDataEntity.friendshipRequestAccepted(
          actorId: data.actorId,
          actorName: data.actorName,
          actorFriendshipCode: data.actorFriendshipCode,
          requestId: data.requestId,
          routeTab: data.routeTab,
        ),
      MemeReceivedNotificationDataDto data =>
        NotificationListPageItemDataEntity.memeReceived(
          actorId: data.actorId,
          actorName: data.actorName,
          memeId: data.memeId,
          memeImagePath: data.memeImagePath,
          memeAspectRatio: data.memeAspectRatio,
          signedMemeImageUrl: data.signedMemeImageUrl,
          routeTab: data.routeTab,
        ),
    };
  }
}
