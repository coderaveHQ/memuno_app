import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_cursor_entity.freezed.dart';

/// Cursor payload used by `notifications_list` pagination.
@freezed
sealed class NotificationCursorEntity with _$NotificationCursorEntity {
  /// Creates a notification cursor entity.
  const factory NotificationCursorEntity({
    /// Last seen `created_at` used for descending timestamp pagination.
    required DateTime createdAt,

    /// Stable notification id used as tie-breaker cursor.
    required String id,
  }) = _NotificationCursorEntity;

  const NotificationCursorEntity._();
}
