import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_data_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_type.dart';

part 'notification_list_page_item_entity.freezed.dart';

/// Domain entity matching `public.notification_list_page_item`.
@freezed
sealed class NotificationListPageItemEntity
    with _$NotificationListPageItemEntity {
  /// Creates one notification-list item entity.
  const factory NotificationListPageItemEntity({
    /// Notification identifier from `public.notifications.id`.
    required String id,

    /// Notification type from `public.notification_type`.
    required NotificationType type,

    /// Strongly typed notification data payload.
    required NotificationListPageItemDataEntity data,

    /// Read state for the recipient.
    required bool isRead,

    /// Notification creation timestamp.
    required DateTime createdAt,

    /// Notification update timestamp.
    required DateTime updatedAt,
  }) = _NotificationListPageItemEntity;

  const NotificationListPageItemEntity._();
}

/// Convenience helpers used by list rendering and optimistic updates.
extension NotificationListPageItemEntityX on NotificationListPageItemEntity {
  /// Stable notification id.
  String get notificationId => id;

  /// Read state used for optimistic updates.
  bool get notificationIsRead => isRead;

  /// Creation timestamp used for list rendering.
  DateTime get notificationCreatedAt => createdAt;

  /// Actor display name used by list item tiles.
  String get notificationActorName {
    return switch (data) {
      FriendshipRequestSentNotificationListPageItemDataEntity(
        :final actorName,
      ) =>
        actorName,
      FriendshipRequestAcceptedNotificationListPageItemDataEntity(
        :final actorName,
      ) =>
        actorName,
      MemeReceivedNotificationListPageItemDataEntity(:final actorName) =>
        actorName,
    };
  }

  /// Notification category.
  NotificationType get notificationType => type;

  /// Signed meme preview URL for `meme_received` notifications.
  String? get notificationMemeSignedImageUrl {
    return switch (data) {
      MemeReceivedNotificationListPageItemDataEntity(
        :final signedMemeImageUrl,
      ) =>
        signedMemeImageUrl,
      _ => null,
    };
  }

  /// Persisted meme aspect ratio for `meme_received` notifications.
  double? get notificationMemeAspectRatio {
    return switch (data) {
      MemeReceivedNotificationListPageItemDataEntity(:final memeAspectRatio) =>
        memeAspectRatio,
      _ => null,
    };
  }

  /// Returns a copy marked as read.
  NotificationListPageItemEntity markRead() => copyWith(isRead: true);

  /// Returns a copy marked as unread.
  NotificationListPageItemEntity markUnread() => copyWith(isRead: false);
}
