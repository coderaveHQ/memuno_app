import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/usecases/list_group_details_memes_all_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/list_group_details_memes_all_usecase.dart';
import 'package:memuno_app/src/features/user_details/application/providers/usecases/toggle_user_details_meme_laugh_usecase_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/toggle_user_details_meme_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_memes_all_list_provider.g.dart';

/// Async paginated controller for all group-details memes.
@Riverpod(keepAlive: true)
class GroupDetailsMemesAllList extends _$GroupDetailsMemesAllList
    with
        AsyncPaginationMixin<MemeItemEntity, ListCursorEntity>,
        OptimisticAsyncStateMixin<
          PaginatedListState<MemeItemEntity, ListCursorEntity>
        > {
  @override
  Future<PaginatedListState<MemeItemEntity, ListCursorEntity>> build(
    String groupId,
  ) {
    return buildPaginatedState();
  }

  @override
  Future<PaginatedPage<MemeItemEntity, ListCursorEntity>> loadPage({
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    final ListGroupDetailsMemesAllUsecase usecase = ref.watch(
      listGroupDetailsMemesAllUsecaseProvider,
    );
    final ListPageEntity<MemeItemEntity> page = await usecase(
      groupId: groupId,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<MemeItemEntity, ListCursorEntity>(
      items: page.items,
      nextCursor: _cursorFromPage(page),
    );
  }

  /// Refreshes the list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next list page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Toggles the current user's laugh state for one listed meme.
  Future<void> toggleMemeLaugh(MemeItemEntity item) async {
    final PaginatedListState<MemeItemEntity, ListCursorEntity>? current =
        state.asData?.value;
    if (current == null) {
      return;
    }

    final String memeId = item.id;
    final int index = current.items.indexWhere((MemeItemEntity currentItem) {
      return currentItem.id == memeId;
    });
    if (index < 0) {
      return;
    }

    final MemeItemEntity currentItem = current.items[index];
    final String? currentUserId = ref.read(currentUserProvider)?.id;
    if (currentUserId != null && currentItem.user.id == currentUserId) {
      return;
    }

    final bool wasLaughed = currentItem.isLaughed;
    final int previousCount = currentItem.laughCount;
    final bool nextLaughed = !wasLaughed;
    final int nextCount = nextLaughed
        ? previousCount + 1
        : (previousCount - 1).clamp(0, previousCount).toInt();

    await runOptimisticUpdate<bool>(
      apply: (PaginatedListState<MemeItemEntity, ListCursorEntity> state) {
        return _setMemeLaughState(
          state,
          memeId: memeId,
          isLaughed: nextLaughed,
          laughCount: nextCount,
        );
      },
      rollback: (PaginatedListState<MemeItemEntity, ListCursorEntity> state) {
        return _setMemeLaughState(
          state,
          memeId: memeId,
          isLaughed: wasLaughed,
          laughCount: previousCount,
        );
      },
      operation: () {
        final ToggleUserDetailsMemeLaughUsecase usecase = ref.read(
          toggleUserDetailsMemeLaughUsecaseProvider,
        );
        return usecase(memeId: memeId);
      },
    );
  }

  PaginatedListState<MemeItemEntity, ListCursorEntity> _setMemeLaughState(
    PaginatedListState<MemeItemEntity, ListCursorEntity> state, {
    required String memeId,
    required bool isLaughed,
    required int laughCount,
  }) {
    final List<MemeItemEntity> nextItems = state.items
        .map((MemeItemEntity item) {
          if (item.id != memeId) {
            return item;
          }

          return item.copyWith(isLaughed: isLaughed, laughCount: laughCount);
        })
        .toList(growable: false);

    return state.copyWith(items: List<MemeItemEntity>.unmodifiable(nextItems));
  }

  ListCursorEntity? _cursorFromPage(ListPageEntity<MemeItemEntity> page) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return ListCursorEntity(createdAt: createdAt, id: id);
  }
}
