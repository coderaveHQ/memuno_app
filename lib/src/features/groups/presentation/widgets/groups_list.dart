import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/features/groups/application/providers/groups_list_provider.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:memuno_app/src/features/groups/presentation/widgets/group_list_item.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Typed async list wrapper for groups pages.
class MAsyncGroupsList extends StatelessWidget {
  const MAsyncGroupsList({
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
    PaginatedListState<GroupItemEntity, ListCursorEntity>
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
    return MAsyncList<GroupItemEntity, ListCursorEntity>(
      provider: provider ?? groupsListProvider,
      emptyText: emptyText,
      loadMoreExtent: loadMoreExtent,
      onRefresh: onRefresh,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      itemBuilder: (BuildContext context, GroupItemEntity group) {
        return GroupListItem(group: group);
      },
    );
  }
}
