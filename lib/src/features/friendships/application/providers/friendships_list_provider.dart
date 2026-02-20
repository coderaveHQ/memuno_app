import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/delete_friendship_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/list_friendships_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/delete_friendship_usecase.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/list_friendships_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'friendships_list_provider.g.dart';

/// Async paginated controller for active friendships.
@Riverpod(keepAlive: true)
class FriendshipsList extends _$FriendshipsList
    with
        AsyncPaginationMixin<FriendshipEntity, FriendshipCursorEntity>,
        AsyncPaginationSearchMixin<FriendshipEntity, FriendshipCursorEntity>,
        OptimisticAsyncStateMixin<
          PaginatedListState<FriendshipEntity, FriendshipCursorEntity>
        > {
  @override
  /// Builds the initial friendships page.
  Future<PaginatedListState<FriendshipEntity, FriendshipCursorEntity>> build() {
    return buildSearchPaginatedState();
  }

  @override
  /// Loads one friendships page from the list usecase.
  Future<PaginatedPage<FriendshipEntity, FriendshipCursorEntity>> loadPage({
    required int limit,
    FriendshipCursorEntity? cursor,
  }) async {
    final ListFriendshipsUsecase usecase = ref.watch(
      listFriendshipsUsecaseProvider,
    );
    return usecase(search: searchQuery, limit: limit, cursor: cursor);
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
  Future<void> removeFriendship(FriendshipEntity friendship) async {
    final PaginatedListState<FriendshipEntity, FriendshipCursorEntity>?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final int originalIndex = current.items.indexWhere(
      (FriendshipEntity item) => item.user.id == friendship.user.id,
    );
    if (originalIndex < 0) {
      return;
    }

    await runOptimisticUpdate<void>(
      apply:
          (PaginatedListState<FriendshipEntity, FriendshipCursorEntity> state) {
            return _removeFriendshipFromState(
              state,
              friendId: friendship.user.id,
            );
          },
      rollback:
          (PaginatedListState<FriendshipEntity, FriendshipCursorEntity> state) {
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

  /// Upserts a friendship entity locally and keeps alphabetical sort order.
  void upsertFriendship(FriendshipEntity friendship) {
    final PaginatedListState<FriendshipEntity, FriendshipCursorEntity>?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final List<FriendshipEntity> nextItems =
        current.items
            .where(
              (FriendshipEntity item) => item.user.id != friendship.user.id,
            )
            .toList(growable: true)
          ..add(friendship)
          ..sort(_compareFriendshipsByNameThenId);

    state =
        AsyncValue<
          PaginatedListState<FriendshipEntity, FriendshipCursorEntity>
        >.data(
          current.copyWith(
            items: List<FriendshipEntity>.unmodifiable(nextItems),
          ),
        );
  }

  /// Returns a copy of [state] without the friendship for [friendId].
  PaginatedListState<FriendshipEntity, FriendshipCursorEntity>
  _removeFriendshipFromState(
    PaginatedListState<FriendshipEntity, FriendshipCursorEntity> state, {
    required String friendId,
  }) {
    final List<FriendshipEntity> nextItems = state.items
        .where((FriendshipEntity item) => item.user.id != friendId)
        .toList(growable: false);

    return state.copyWith(
      items: List<FriendshipEntity>.unmodifiable(nextItems),
    );
  }

  /// Restores [friendship] at [originalIndex] if currently absent.
  PaginatedListState<FriendshipEntity, FriendshipCursorEntity>
  _restoreFriendshipInState({
    required PaginatedListState<FriendshipEntity, FriendshipCursorEntity> state,
    required FriendshipEntity friendship,
    required int originalIndex,
  }) {
    final bool alreadyPresent = state.items.any(
      (FriendshipEntity item) => item.user.id == friendship.user.id,
    );
    if (alreadyPresent) {
      return state;
    }

    final List<FriendshipEntity> nextItems = List<FriendshipEntity>.of(
      state.items,
      growable: true,
    );
    final int safeIndex = originalIndex.clamp(0, nextItems.length);
    nextItems.insert(safeIndex, friendship);

    return state.copyWith(
      items: List<FriendshipEntity>.unmodifiable(nextItems),
    );
  }

  /// Sorts friendships by lowercased name, then by stable id.
  int _compareFriendshipsByNameThenId(
    FriendshipEntity left,
    FriendshipEntity right,
  ) {
    final int byName = left.user.name.toLowerCase().compareTo(
      right.user.name.toLowerCase(),
    );
    if (byName != 0) {
      return byName;
    }
    return left.user.id.compareTo(right.user.id);
  }
}
