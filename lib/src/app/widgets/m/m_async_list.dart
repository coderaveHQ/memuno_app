import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_progress_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_divider.dart';
import 'package:memuno_app/src/app/widgets/m/m_refresh_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_reload.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class MAsyncList<TItem, TCursor> extends ConsumerWidget {
  final $AsyncNotifierProvider<dynamic, PaginatedListState<TItem, TCursor>>
  provider;
  final String emptyText;
  final double loadMoreExtent;
  final EdgeInsetsGeometry? listPadding;
  final EdgeInsetsGeometry? childPadding;
  final EdgeInsetsGeometry? listChildPadding;
  final Widget Function(BuildContext, TItem) itemBuilder;

  const MAsyncList({
    super.key,
    required this.provider,
    required this.emptyText,
    required this.loadMoreExtent,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
    required this.itemBuilder,
  });

  Future<void> _onRefresh(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      await ref.read(provider.notifier).refresh();
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }
  }

  Future<void> _onLoadMore(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      await ref.read(provider.notifier).loadMore();
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }
  }

  int _itemCount(PaginatedListState<TItem, TCursor> state) {
    if (state.items.isEmpty) {
      return 1;
    }

    final bool showTail = state.isLoadingMore || state.hasMore;
    return state.items.length + (showTail ? 1 : 0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppFeedback feedback = ref.read(appFeedbackProvider);

    final AsyncValue<PaginatedListState<TItem, TCursor>> asyncItems = ref.watch(
      provider,
    );

    final EdgeInsetsGeometry safeChildPadding =
        childPadding ??
        EdgeInsets.only(
          top: MSpacing.md,
          bottom: context.bottomPadding + MSpacing.md,
          left: context.leftPadding + MSpacing.md,
          right: context.rightPadding + MSpacing.md,
        );

    final EdgeInsetsGeometry safeListPadding =
        listPadding ?? EdgeInsets.only(bottom: context.bottomPadding);

    final EdgeInsetsGeometry safeListChildPadding =
        listChildPadding ??
        EdgeInsets.only(
          top: MSpacing.md,
          bottom: MSpacing.md,
          left: context.leftPadding + MSpacing.md,
          right: context.rightPadding + MSpacing.md,
        );

    return asyncItems.when(
      data: (PaginatedListState<TItem, TCursor> itemsState) {
        final List<TItem> items = itemsState.items;
        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification notification) {
            if (notification.metrics.extentAfter < loadMoreExtent) {
              unawaited(_onLoadMore(ref, context, feedback));
            }
            return false;
          },
          child: MRefreshIndicator(
            onRefresh: () => _onRefresh(ref, context, feedback),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _itemCount(itemsState),
              padding: safeListPadding,
              separatorBuilder: (BuildContext context, int index) {
                return const MDivider();
              },
              itemBuilder: (BuildContext context, int index) {
                if (items.isEmpty) {
                  return MReload(
                    onReload: () => _onRefresh(ref, context, feedback),
                    padding: safeListChildPadding,
                    text: emptyText,
                  );
                }

                if (index >= items.length) {
                  if (!itemsState.isLoadingMore) {
                    return const SizedBox.shrink();
                  }

                  return MCenter(
                    padding: safeListChildPadding,
                    child: const MCircularProgressIndicator(),
                  );
                }

                final TItem item = items[index];
                return itemBuilder.call(context, item);
              },
            ),
          ),
        );
      },
      error: (Object e, StackTrace _) {
        final String message = feedback.resolve(context, e);
        return MReload(
          onReload: () => _onRefresh(ref, context, feedback),
          padding: safeChildPadding,
          text: message,
        );
      },
      loading: () {
        return MCenter(
          padding: safeChildPadding,
          child: const MCircularProgressIndicator(),
        );
      },
    );
  }
}
