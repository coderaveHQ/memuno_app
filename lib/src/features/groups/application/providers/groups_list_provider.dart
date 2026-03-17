import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/groups/application/providers/usecases/list_groups_usecase_provider.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/list_groups_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'groups_list_provider.g.dart';

/// Async paginated controller for group memberships.
@Riverpod(keepAlive: true)
class GroupsList extends _$GroupsList
    with
        AsyncPaginationMixin<GroupItemEntity, ListCursorEntity>,
        AsyncPaginationSearchMixin<GroupItemEntity, ListCursorEntity> {
  @override
  Future<PaginatedListState<GroupItemEntity, ListCursorEntity>> build() {
    return buildSearchPaginatedState();
  }

  @override
  Future<PaginatedPage<GroupItemEntity, ListCursorEntity>> loadPage({
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    final ListGroupsUsecase usecase = ref.watch(listGroupsUsecaseProvider);
    final ListPageEntity<GroupItemEntity> page = await usecase(
      search: searchQuery,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<GroupItemEntity, ListCursorEntity>(
      items: page.items,
      nextCursor: _cursorFromPage(page),
    );
  }

  /// Refreshes the groups list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next groups page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Upserts one group in local state and keeps backend sort ordering.
  void upsertGroup(GroupItemEntity group) {
    final PaginatedListState<GroupItemEntity, ListCursorEntity>? current =
        state.asData?.value;
    if (current == null) {
      return;
    }

    final List<GroupItemEntity> nextItems =
        current.items
            .where((GroupItemEntity item) => item.id != group.id)
            .toList(growable: true)
          ..add(group)
          ..sort(_compareGroupsByCreatedAtThenId);

    state =
        AsyncValue<PaginatedListState<GroupItemEntity, ListCursorEntity>>.data(
          current.copyWith(
            items: List<GroupItemEntity>.unmodifiable(nextItems),
          ),
        );
  }

  int _compareGroupsByCreatedAtThenId(
    GroupItemEntity left,
    GroupItemEntity right,
  ) {
    final int byCreatedAt = right.createdAt.compareTo(left.createdAt);
    if (byCreatedAt != 0) {
      return byCreatedAt;
    }
    return right.id.compareTo(left.id);
  }

  ListCursorEntity? _cursorFromPage(ListPageEntity<GroupItemEntity> page) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }
    return ListCursorEntity(createdAt: createdAt, id: id);
  }
}
