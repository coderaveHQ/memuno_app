import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_cursor_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_entity.dart';
import 'package:memuno_app/src/features/notifications/presentation/widgets/notification_list_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Typed async list wrapper for notification pages.
class MAsyncNotificationList extends StatelessWidget {
  const MAsyncNotificationList({
    super.key,
    required this.provider,
    required this.emptyText,
    required this.onPressed,
    this.loadMoreExtent = 220.0,
    this.onRefresh,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
  });

  final $AsyncNotifierProvider<
    dynamic,
    PaginatedListState<NotificationListPageItemEntity, NotificationCursorEntity>
  >
  provider;
  final String emptyText;
  final void Function(NotificationListPageItemEntity notification) onPressed;
  final double loadMoreExtent;
  final Future<void> Function(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  )?
  onRefresh;
  final EdgeInsetsGeometry? listPadding;
  final EdgeInsetsGeometry? childPadding;
  final EdgeInsetsGeometry? listChildPadding;

  @override
  Widget build(BuildContext context) {
    return MAsyncList<NotificationListPageItemEntity, NotificationCursorEntity>(
      provider: provider,
      emptyText: emptyText,
      loadMoreExtent: loadMoreExtent,
      onRefresh: onRefresh,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      itemBuilder:
          (BuildContext context, NotificationListPageItemEntity notification) {
            return MAsyncNotificationListItem(
              notification: notification,
              onPressed: onPressed,
            );
          },
    );
  }
}
