// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/notifications/data/dto/notification_dto.dart';

part 'notifications_page_dto.freezed.dart';
part 'notifications_page_dto.g.dart';

/// DTO representing one paginated `notifications_list` response.
@freezed
sealed class NotificationsPageDto with _$NotificationsPageDto {
  /// Creates a notifications page DTO.
  const factory NotificationsPageDto({
    /// Notification items contained in the page.
    required List<NotificationDto> items,

    /// Next cursor created-at value for pagination.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor id value for pagination.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _NotificationsPageDto;

  /// Creates a notifications page DTO from JSON.
  factory NotificationsPageDto.fromJson(Map<String, Object?> json) =>
      _$NotificationsPageDtoFromJson(json);
}
