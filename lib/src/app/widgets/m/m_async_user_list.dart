import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_user_list_item.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Typed async list wrapper for canonical `user_item` pages.
class MAsyncUserList extends StatelessWidget {
  const MAsyncUserList({
    super.key,
    required this.provider,
    required this.emptyText,
    this.loadMoreExtent = 220.0,
    this.onRefresh,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
    this.onPressed,
    this.isEnabled = true,
    this.showFriendshipCode = true,
    this.showSelectionIndicator = false,
    this.selectedUserIds = const <String>{},
  });

  final $AsyncNotifierProvider<
    dynamic,
    PaginatedListState<UserItemEntity, ListCursorEntity>
  >
  provider;
  final String emptyText;
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
  final void Function(UserItemEntity user)? onPressed;
  final bool isEnabled;
  final bool showFriendshipCode;
  final bool showSelectionIndicator;
  final Set<String> selectedUserIds;

  @override
  Widget build(BuildContext context) {
    return MAsyncList<UserItemEntity, ListCursorEntity>(
      provider: provider,
      emptyText: emptyText,
      loadMoreExtent: loadMoreExtent,
      onRefresh: onRefresh,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      itemBuilder: (BuildContext context, UserItemEntity item) {
        return MAsyncUserListItem(
          item: item,
          onPressed: onPressed,
          isEnabled: isEnabled,
          showFriendshipCode: showFriendshipCode,
          showSelectionIndicator: showSelectionIndicator,
          isSelected: selectedUserIds.contains(item.id),
        );
      },
    );
  }
}
