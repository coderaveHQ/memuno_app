import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_type.dart';

part 'notification_entity.freezed.dart';

/// Polymorphic notification entity used by list and tap handlers.
@freezed
sealed class NotificationEntity with _$NotificationEntity {
  /// Notification for an incoming friendship request.
  const factory NotificationEntity.friendshipRequestSent({
    required String id,
    required bool isRead,
    required DateTime createdAt,
    required String actorId,
    required String actorName,
    required String actorFriendshipCode,
    required String requestId,
    required String routeTab,
  }) = FriendshipRequestSentNotificationEntity;

  /// Notification for an accepted outgoing friendship request.
  const factory NotificationEntity.friendshipRequestAccepted({
    required String id,
    required bool isRead,
    required DateTime createdAt,
    required String actorId,
    required String actorName,
    required String actorFriendshipCode,
    required String requestId,
    required String routeTab,
  }) = FriendshipRequestAcceptedNotificationEntity;

  /// Notification for a newly received meme.
  const factory NotificationEntity.memeReceived({
    required String id,
    required bool isRead,
    required DateTime createdAt,
    required String actorId,
    required String actorName,
    required String memeId,
    required String? routeTab,
  }) = MemeReceivedNotificationEntity;

  const NotificationEntity._();
}

/// Convenience helpers for shared notification access and state transitions.
extension NotificationEntityX on NotificationEntity {
  /// Stable notification id.
  String get notificationId {
    return switch (this) {
      FriendshipRequestSentNotificationEntity(:final id) => id,
      FriendshipRequestAcceptedNotificationEntity(:final id) => id,
      MemeReceivedNotificationEntity(:final id) => id,
    };
  }

  /// Read state used for optimistic updates.
  bool get notificationIsRead {
    return switch (this) {
      FriendshipRequestSentNotificationEntity(:final isRead) => isRead,
      FriendshipRequestAcceptedNotificationEntity(:final isRead) => isRead,
      MemeReceivedNotificationEntity(:final isRead) => isRead,
    };
  }

  /// Creation timestamp used for list rendering.
  DateTime get notificationCreatedAt {
    return switch (this) {
      FriendshipRequestSentNotificationEntity(:final createdAt) => createdAt,
      FriendshipRequestAcceptedNotificationEntity(:final createdAt) =>
        createdAt,
      MemeReceivedNotificationEntity(:final createdAt) => createdAt,
    };
  }

  /// Actor display name used by the list item tiles.
  String get notificationActorName {
    return switch (this) {
      FriendshipRequestSentNotificationEntity(:final actorName) => actorName,
      FriendshipRequestAcceptedNotificationEntity(:final actorName) =>
        actorName,
      MemeReceivedNotificationEntity(:final actorName) => actorName,
    };
  }

  /// Notification category.
  NotificationType get notificationType {
    return switch (this) {
      FriendshipRequestSentNotificationEntity() =>
        NotificationType.friendshipRequestSent,
      FriendshipRequestAcceptedNotificationEntity() =>
        NotificationType.friendshipRequestAccepted,
      MemeReceivedNotificationEntity() => NotificationType.memeReceived,
    };
  }

  /// Returns a copy marked as read.
  NotificationEntity markRead() {
    return switch (this) {
      FriendshipRequestSentNotificationEntity notification =>
        notification.copyWith(isRead: true),
      FriendshipRequestAcceptedNotificationEntity notification =>
        notification.copyWith(isRead: true),
      MemeReceivedNotificationEntity notification => notification.copyWith(
        isRead: true,
      ),
    };
  }

  /// Returns a copy marked as unread.
  NotificationEntity markUnread() {
    return switch (this) {
      FriendshipRequestSentNotificationEntity notification =>
        notification.copyWith(isRead: false),
      FriendshipRequestAcceptedNotificationEntity notification =>
        notification.copyWith(isRead: false),
      MemeReceivedNotificationEntity notification => notification.copyWith(
        isRead: false,
      ),
    };
  }
}
