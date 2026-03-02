import 'package:memuno_app/src/features/notifications/data/dto/notification_dto.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_type.dart';

/// Maps [NotificationDto] values into polymorphic [NotificationEntity] values.
final class NotificationMapper {
  /// Creates a mapper.
  const NotificationMapper();

  /// Maps one notification DTO to its concrete domain entity variant.
  NotificationEntity toDomain(NotificationDto dto) {
    final NotificationType type = NotificationType.fromDatabaseValue(dto.type);

    return switch (type) {
      NotificationType.friendshipRequestSent => _mapFriendshipRequestSent(dto),
      NotificationType.friendshipRequestAccepted =>
        _mapFriendshipRequestAccepted(dto),
      NotificationType.memeReceived => _mapMemeReceived(dto),
    };
  }

  NotificationEntity _mapFriendshipRequestSent(NotificationDto dto) {
    final Map<String, Object?> payload = dto.data;
    final String routeTab = _readRequiredString(payload, 'route_tab');

    if (routeTab != 'requests') {
      throw FormatException(
        'Expected route_tab=requests for friendship_request_sent.',
      );
    }

    return NotificationEntity.friendshipRequestSent(
      id: dto.id,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
      actorId: _readRequiredString(payload, 'actor_id'),
      actorName: _readRequiredString(payload, 'actor_name'),
      actorFriendshipCode: _readRequiredString(
        payload,
        'actor_friendship_code',
      ),
      requestId: _readRequiredString(payload, 'request_id'),
      routeTab: routeTab,
    );
  }

  NotificationEntity _mapFriendshipRequestAccepted(NotificationDto dto) {
    final Map<String, Object?> payload = dto.data;
    final String routeTab = _readRequiredString(payload, 'route_tab');

    if (routeTab != 'friendships') {
      throw FormatException(
        'Expected route_tab=friendships for friendship_request_accepted.',
      );
    }

    return NotificationEntity.friendshipRequestAccepted(
      id: dto.id,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
      actorId: _readRequiredString(payload, 'actor_id'),
      actorName: _readRequiredString(payload, 'actor_name'),
      actorFriendshipCode: _readRequiredString(
        payload,
        'actor_friendship_code',
      ),
      requestId: _readRequiredString(payload, 'request_id'),
      routeTab: routeTab,
    );
  }

  NotificationEntity _mapMemeReceived(NotificationDto dto) {
    final Map<String, Object?> payload = dto.data;
    if (!payload.containsKey('route_tab') || payload['route_tab'] != null) {
      throw FormatException('Expected route_tab=null for meme_received.');
    }

    return NotificationEntity.memeReceived(
      id: dto.id,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
      actorId: _readRequiredString(payload, 'actor_id'),
      actorName: _readRequiredString(payload, 'actor_name'),
      memeId: _readRequiredString(payload, 'meme_id'),
      routeTab: null,
    );
  }

  String _readRequiredString(Map<String, Object?> payload, String key) {
    final Object? value = payload[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Expected non-empty string field `$key`.');
    }
    return value;
  }
}
