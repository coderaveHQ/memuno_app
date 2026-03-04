import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_entity.dart';

part 'notification_list_page_entity.freezed.dart';

/// Domain entity matching `public.notification_list_page`.
@freezed
sealed class NotificationListPageEntity with _$NotificationListPageEntity {
  /// Creates one notification-list page entity.
  const factory NotificationListPageEntity({
    /// Page items.
    required List<NotificationListPageItemEntity> items,

    /// Next cursor `created_at` value.
    DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    String? nextCursorId,
  }) = _NotificationListPageEntity;

  const NotificationListPageEntity._();
}
