import 'package:memuno_app/src/features/notifications/domain/entities/notification_type.dart';

/// Strongly typed DTO hierarchy for `public.notifications.data`.
sealed class NotificationListPageItemDataDto {
  const NotificationListPageItemDataDto();

  /// Parses one notification data payload based on [type].
  factory NotificationListPageItemDataDto.fromJson({
    required NotificationType type,
    required Map<String, Object?> json,
  }) {
    return switch (type) {
      NotificationType.friendshipRequestSent =>
        FriendshipRequestSentNotificationDataDto.fromJson(json),
      NotificationType.friendshipRequestAccepted =>
        FriendshipRequestAcceptedNotificationDataDto.fromJson(json),
      NotificationType.memeReceived => MemeReceivedNotificationDataDto.fromJson(
        json,
      ),
      NotificationType.memeLaughed => MemeLaughedNotificationDataDto.fromJson(
        json,
      ),
    };
  }
}

/// DTO for `friendship_request_sent` notification data.
final class FriendshipRequestSentNotificationDataDto
    extends NotificationListPageItemDataDto {
  const FriendshipRequestSentNotificationDataDto({
    required this.actorId,
    required this.actorName,
    required this.actorFriendshipCode,
    required this.requestId,
    required this.routeTab,
  });

  factory FriendshipRequestSentNotificationDataDto.fromJson(
    Map<String, Object?> json,
  ) {
    final String routeTab = _readRequiredString(json, 'route_tab');
    if (routeTab != 'requests') {
      throw FormatException(
        'Expected route_tab=requests for friendship_request_sent.',
      );
    }

    return FriendshipRequestSentNotificationDataDto(
      actorId: _readRequiredString(json, 'actor_id'),
      actorName: _readRequiredString(json, 'actor_name'),
      actorFriendshipCode: _readRequiredString(json, 'actor_friendship_code'),
      requestId: _readRequiredString(json, 'request_id'),
      routeTab: routeTab,
    );
  }

  final String actorId;
  final String actorName;
  final String actorFriendshipCode;
  final String requestId;
  final String routeTab;
}

/// DTO for `friendship_request_accepted` notification data.
final class FriendshipRequestAcceptedNotificationDataDto
    extends NotificationListPageItemDataDto {
  const FriendshipRequestAcceptedNotificationDataDto({
    required this.actorId,
    required this.actorName,
    required this.actorFriendshipCode,
    required this.requestId,
    required this.routeTab,
  });

  factory FriendshipRequestAcceptedNotificationDataDto.fromJson(
    Map<String, Object?> json,
  ) {
    final String routeTab = _readRequiredString(json, 'route_tab');
    if (routeTab != 'friendships') {
      throw FormatException(
        'Expected route_tab=friendships for friendship_request_accepted.',
      );
    }

    return FriendshipRequestAcceptedNotificationDataDto(
      actorId: _readRequiredString(json, 'actor_id'),
      actorName: _readRequiredString(json, 'actor_name'),
      actorFriendshipCode: _readRequiredString(json, 'actor_friendship_code'),
      requestId: _readRequiredString(json, 'request_id'),
      routeTab: routeTab,
    );
  }

  final String actorId;
  final String actorName;
  final String actorFriendshipCode;
  final String requestId;
  final String routeTab;
}

/// DTO for `meme_received` notification data.
final class MemeReceivedNotificationDataDto
    extends NotificationListPageItemDataDto {
  const MemeReceivedNotificationDataDto({
    required this.actorId,
    required this.actorName,
    required this.memeId,
    required this.memePushImagePath,
    required this.memeAspectRatio,
    required this.signedMemeImageUrl,
    required this.routeTab,
  });

  factory MemeReceivedNotificationDataDto.fromJson(Map<String, Object?> json) {
    final Object? routeTab = json['route_tab'];
    if (routeTab != null) {
      throw const FormatException('Expected route_tab=null for meme_received.');
    }

    return MemeReceivedNotificationDataDto(
      actorId: _readRequiredString(json, 'actor_id'),
      actorName: _readRequiredString(json, 'actor_name'),
      memeId: _readRequiredString(json, 'meme_id'),
      memePushImagePath: _readNullableString(json, 'push_image_path'),
      memeAspectRatio: _readRequiredPositiveDouble(json, 'aspect_ratio'),
      signedMemeImageUrl: null,
      routeTab: null,
    );
  }

  final String actorId;
  final String actorName;
  final String memeId;
  final String? memePushImagePath;
  final double memeAspectRatio;
  final String? signedMemeImageUrl;
  final String? routeTab;
}

/// DTO for `meme_laughed` notification data.
final class MemeLaughedNotificationDataDto
    extends NotificationListPageItemDataDto {
  const MemeLaughedNotificationDataDto({
    required this.actorId,
    required this.actorName,
    required this.memeId,
    required this.memePushImagePath,
    required this.memeAspectRatio,
    required this.signedMemeImageUrl,
    required this.routeTab,
  });

  factory MemeLaughedNotificationDataDto.fromJson(Map<String, Object?> json) {
    final Object? routeTab = json['route_tab'];
    if (routeTab != null) {
      throw const FormatException('Expected route_tab=null for meme_laughed.');
    }

    return MemeLaughedNotificationDataDto(
      actorId: _readRequiredString(json, 'actor_id'),
      actorName: _readRequiredString(json, 'actor_name'),
      memeId: _readRequiredString(json, 'meme_id'),
      memePushImagePath: _readNullableString(json, 'push_image_path'),
      memeAspectRatio: _readRequiredPositiveDouble(json, 'aspect_ratio'),
      signedMemeImageUrl: null,
      routeTab: null,
    );
  }

  final String actorId;
  final String actorName;
  final String memeId;
  final String? memePushImagePath;
  final double memeAspectRatio;
  final String? signedMemeImageUrl;
  final String? routeTab;
}

String _readRequiredString(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty string field `$key`.');
  }
  return value;
}

double _readRequiredPositiveDouble(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! num) {
    throw FormatException('Expected numeric field `$key`.');
  }

  final double parsed = value.toDouble();
  if (parsed <= 0) {
    throw FormatException('Expected positive numeric field `$key`.');
  }

  return parsed;
}

String? _readNullableString(Map<String, Object?> payload, String key) {
  if (!payload.containsKey(key)) {
    throw FormatException('Expected nullable string field `$key`.');
  }

  final Object? value = payload[key];
  if (value == null) {
    return null;
  }

  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected nullable string field `$key`.');
  }

  return value;
}
