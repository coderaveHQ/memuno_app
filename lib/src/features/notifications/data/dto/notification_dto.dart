// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_dto.freezed.dart';
part 'notification_dto.g.dart';

/// DTO representing one notification item returned by `notifications_list`.
@freezed
sealed class NotificationDto with _$NotificationDto {
  /// Creates a notification DTO.
  const factory NotificationDto({
    /// Notification identifier from `public.notifications.id`.
    required String id,

    /// Raw enum value from `public.notification_type`.
    required String type,

    /// Type-specific payload from `public.notifications.data`.
    required Map<String, Object?> data,

    /// Read state for the recipient.
    @JsonKey(name: 'is_read') required bool isRead,

    /// Notification creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _NotificationDto;

  /// Creates a notification DTO from JSON.
  factory NotificationDto.fromJson(Map<String, Object?> json) =>
      _$NotificationDtoFromJson(json);
}
