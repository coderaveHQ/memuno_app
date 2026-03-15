import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/delete_friendship_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/list_friendships_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/delete_friendship_usecase.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/list_friendships_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'friendships_list_provider.g.dart';

/// Async paginated controller for active friendships.
@Riverpod(keepAlive: true)
class FriendshipsList extends _$FriendshipsList
    with
        AsyncPaginationMixin<
          FriendshipListPageItemEntity,
          FriendshipCursorEntity
        >,
        AsyncPaginationSearchMixin<
          FriendshipListPageItemEntity,
          FriendshipCursorEntity
        >,
        OptimisticAsyncStateMixin<
          PaginatedListState<
            FriendshipListPageItemEntity,
            FriendshipCursorEntity
          >
        > {
  @override
  /// Builds the initial friendships page.
  Future<
    PaginatedListState<FriendshipListPageItemEntity, FriendshipCursorEntity>
  >
  build() {
    return buildSearchPaginatedState();
  }

  @override
  /// Loads one friendships page from the list usecase.
  Future<PaginatedPage<FriendshipListPageItemEntity, FriendshipCursorEntity>>
  loadPage({required int limit, FriendshipCursorEntity? cursor}) async {
    final ListFriendshipsUsecase usecase = ref.watch(
      listFriendshipsUsecaseProvider,
    );
    final FriendshipListPageEntity page = await usecase(
      search: searchQuery,
      limit: limit,
      cursor: cursor,
    );
    return PaginatedPage<FriendshipListPageItemEntity, FriendshipCursorEntity>(
      items: page.items,
      nextCursor: _cursorFromPage(page),
    );
  }

  /// Refreshes the friendships list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next friendships page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Removes one friendship with optimistic rollback support.
  Future<void> removeFriendship(FriendshipListPageItemEntity friendship) async {
    final PaginatedListState<
      FriendshipListPageItemEntity,
      FriendshipCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final int originalIndex = current.items.indexWhere(
      (FriendshipListPageItemEntity item) => item.user.id == friendship.user.id,
    );
    if (originalIndex < 0) {
      return;
    }

    await runOptimisticUpdate<void>(
      apply:
          (
            PaginatedListState<
              FriendshipListPageItemEntity,
              FriendshipCursorEntity
            >
            state,
          ) {
            return _removeFriendshipFromState(
              state,
              friendId: friendship.user.id,
            );
          },
      rollback:
          (
            PaginatedListState<
              FriendshipListPageItemEntity,
              FriendshipCursorEntity
            >
            state,
          ) {
            return _restoreFriendshipInState(
              state: state,
              friendship: friendship,
              originalIndex: originalIndex,
            );
          },
      operation: () async {
        final DeleteFriendshipUsecase usecase = ref.read(
          deleteFriendshipUsecaseProvider,
        );
        await usecase(friendId: friendship.user.id);
      },
    );
  }

  /// Upserts a friendship entity locally and keeps backend sort order.
  void upsertFriendship(FriendshipListPageItemEntity friendship) {
    final PaginatedListState<
      FriendshipListPageItemEntity,
      FriendshipCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final List<FriendshipListPageItemEntity> nextItems =
        current.items
            .where(
              (FriendshipListPageItemEntity item) =>
                  item.user.id != friendship.user.id,
            )
            .toList(growable: true)
          ..add(friendship)
          ..sort(_compareFriendshipsByCreatedAtThenUserId);

    state =
        AsyncValue<
          PaginatedListState<
            FriendshipListPageItemEntity,
            FriendshipCursorEntity
          >
        >.data(
          current.copyWith(
            items: List<FriendshipListPageItemEntity>.unmodifiable(nextItems),
          ),
        );
  }

  /// Returns a copy of [state] without the friendship for [friendId].
  PaginatedListState<FriendshipListPageItemEntity, FriendshipCursorEntity>
  _removeFriendshipFromState(
    PaginatedListState<FriendshipListPageItemEntity, FriendshipCursorEntity>
    state, {
    required String friendId,
  }) {
    final List<FriendshipListPageItemEntity> nextItems = state.items
        .where((FriendshipListPageItemEntity item) => item.user.id != friendId)
        .toList(growable: false);

    return state.copyWith(
      items: List<FriendshipListPageItemEntity>.unmodifiable(nextItems),
    );
  }

  /// Restores [friendship] at [originalIndex] if currently absent.
  PaginatedListState<FriendshipListPageItemEntity, FriendshipCursorEntity>
  _restoreFriendshipInState({
    required PaginatedListState<
      FriendshipListPageItemEntity,
      FriendshipCursorEntity
    >
    state,
    required FriendshipListPageItemEntity friendship,
    required int originalIndex,
  }) {
    final bool alreadyPresent = state.items.any(
      (FriendshipListPageItemEntity item) => item.user.id == friendship.user.id,
    );
    if (alreadyPresent) {
      return state;
    }

    final List<FriendshipListPageItemEntity> nextItems =
        List<FriendshipListPageItemEntity>.of(state.items, growable: true);
    final int safeIndex = originalIndex.clamp(0, nextItems.length);
    nextItems.insert(safeIndex, friendship);

    return state.copyWith(
      items: List<FriendshipListPageItemEntity>.unmodifiable(nextItems),
    );
  }

  /// Sorts friendships by `created_at desc`, then by `friend_id desc`.
  int _compareFriendshipsByCreatedAtThenUserId(
    FriendshipListPageItemEntity left,
    FriendshipListPageItemEntity right,
  ) {
    final int byCreatedAt = right.createdAt.compareTo(left.createdAt);
    if (byCreatedAt != 0) {
      return byCreatedAt;
    }
    return right.user.id.compareTo(left.user.id);
  }

  FriendshipCursorEntity? _cursorFromPage(FriendshipListPageEntity page) {
    final DateTime? nextCursorCreatedAt = page.nextCursorCreatedAt;
    final String? nextCursorId = page.nextCursorId;
    if (nextCursorCreatedAt == null || nextCursorId == null) {
      return null;
    }

    return FriendshipCursorEntity(createdAt: nextCursorCreatedAt, id: nextCursorId);
  }
}
