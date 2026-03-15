import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_meme_list_item.dart';
import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Typed async list wrapper for canonical `meme_item` pages.
class MAsyncMemeList extends StatelessWidget {
  const MAsyncMemeList({
    super.key,
    required this.provider,
    required this.emptyText,
    required this.readToggleMutation,
    required this.onToggleLaugh,
    this.loadMoreExtent = 220.0,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
    this.onRefresh,
    this.separatorBuilder,
    this.onOpenUserDetails,
    this.onOpenMemeDetails,
  });

  final $AsyncNotifierProvider<
    dynamic,
    PaginatedListState<MemeItemEntity, ListCursorEntity>
  >
  provider;
  final String emptyText;
  final double loadMoreExtent;
  final EdgeInsetsGeometry? listPadding;
  final EdgeInsetsGeometry? childPadding;
  final EdgeInsetsGeometry? listChildPadding;
  final Future<void> Function(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  )?
  onRefresh;
  final Widget Function(BuildContext context, int index)? separatorBuilder;
  final MAsyncMemeMutationReader readToggleMutation;
  final MAsyncMemeToggleHandler onToggleLaugh;
  final MAsyncMemeOpenUserHandler? onOpenUserDetails;
  final MAsyncMemeOpenDetailsHandler? onOpenMemeDetails;

  @override
  Widget build(BuildContext context) {
    return MAsyncList<MemeItemEntity, ListCursorEntity>(
      provider: provider,
      emptyText: emptyText,
      loadMoreExtent: loadMoreExtent,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      onRefresh: onRefresh,
      separatorBuilder: separatorBuilder,
      itemBuilder: (BuildContext context, MemeItemEntity item) {
        return MAsyncMemeListItem(
          item: item,
          readToggleMutation: readToggleMutation,
          onToggleLaugh: onToggleLaugh,
          onOpenUserDetails: onOpenUserDetails,
          onOpenMemeDetails: onOpenMemeDetails,
        );
      },
    );
  }
}
