import 'package:memuno_app/src/features/notifications/data/dto/notification_list_page_item_data_dto.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_type.dart';

/// DTO matching `public.notification_list_page_item`.
final class NotificationListPageItemDto {
  const NotificationListPageItemDto({
    required this.id,
    required this.type,
    required this.data,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parses one notification-list item DTO from JSON.
  factory NotificationListPageItemDto.fromJson(Map<String, Object?> json) {
    final NotificationType type = NotificationType.fromDatabaseValue(
      _readRequiredString(json, 'type'),
    );
    final Object? rawData = json['data'];
    if (rawData is! Map) {
      throw const FormatException('Expected `data` to be an object payload.');
    }
    final Map<String, Object?> dataJson = Map<String, Object?>.from(rawData);

    return NotificationListPageItemDto(
      id: _readRequiredString(json, 'id'),
      type: type,
      data: NotificationListPageItemDataDto.fromJson(
        type: type,
        json: dataJson,
      ),
      isRead: _readRequiredBool(json, 'is_read'),
      createdAt: _readRequiredDateTime(json, 'created_at'),
      updatedAt: _readRequiredDateTime(json, 'updated_at'),
    );
  }

  final String id;
  final NotificationType type;
  final NotificationListPageItemDataDto data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;
}

String _readRequiredString(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty string field `$key`.');
  }
  return value;
}

bool _readRequiredBool(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! bool) {
    throw FormatException('Expected boolean field `$key`.');
  }
  return value;
}

DateTime _readRequiredDateTime(Map<String, Object?> payload, String key) {
  final Object? value = payload[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty timestamp field `$key`.');
  }

  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw FormatException('Expected ISO-8601 timestamp field `$key`.');
  }
  return parsed;
}
