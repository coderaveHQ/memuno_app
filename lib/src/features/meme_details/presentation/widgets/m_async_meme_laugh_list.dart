import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/presentation/widgets/meme_laugh_list_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Typed async list wrapper for meme-laugh list pages.
class MAsyncMemeLaughList extends StatelessWidget {
  const MAsyncMemeLaughList({
    super.key,
    required this.provider,
    required this.emptyText,
    this.loadMoreExtent = 220.0,
    this.onRefresh,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
  });

  final $AsyncNotifierProvider<
    dynamic,
    PaginatedListState<MemeLaughListPageItemEntity, MemeLaughCursorEntity>
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

  @override
  Widget build(BuildContext context) {
    return MAsyncList<MemeLaughListPageItemEntity, MemeLaughCursorEntity>(
      provider: provider,
      emptyText: emptyText,
      loadMoreExtent: loadMoreExtent,
      onRefresh: onRefresh,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      itemBuilder: (BuildContext context, MemeLaughListPageItemEntity item) {
        return MAsyncMemeLaughListItem(item: item);
      },
    );
  }
}
