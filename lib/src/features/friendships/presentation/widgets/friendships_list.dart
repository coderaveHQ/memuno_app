import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/m_async_friendship_list_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Typed async list wrapper for friendship list pages.
class MAsyncFriendshipList extends StatelessWidget {
  const MAsyncFriendshipList({
    super.key,
    this.provider,
    required this.emptyText,
    this.loadMoreExtent = 220.0,
    this.onRefresh,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
  });

  final $AsyncNotifierProvider<
    dynamic,
    PaginatedListState<FriendshipListPageItemEntity, FriendshipCursorEntity>
  >?
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

  @override
  Widget build(BuildContext context) {
    return MAsyncList<FriendshipListPageItemEntity, FriendshipCursorEntity>(
      provider: provider ?? friendshipsListProvider,
      emptyText: emptyText,
      loadMoreExtent: loadMoreExtent,
      onRefresh: onRefresh,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      itemBuilder:
          (BuildContext context, FriendshipListPageItemEntity friendship) {
            return MAsyncFriendshipListItem(friendship: friendship);
          },
    );
  }
}
