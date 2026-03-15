import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/usecases/list_user_details_own_sent_memes_usecase_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/usecases/toggle_user_details_meme_laugh_usecase_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/list_user_details_own_sent_memes_usecase.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/toggle_user_details_meme_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_details_own_sent_memes_list_provider.g.dart';

/// Async paginated controller for own-sent user-details memes.
@Riverpod(keepAlive: true)
class UserDetailsOwnSentMemesList extends _$UserDetailsOwnSentMemesList
    with
        AsyncPaginationMixin<
          UserDetailsOwnSentMemesListPageItemEntity,
          UserDetailsOwnSentMemesCursorEntity
        >,
        OptimisticAsyncStateMixin<
          PaginatedListState<
            UserDetailsOwnSentMemesListPageItemEntity,
            UserDetailsOwnSentMemesCursorEntity
          >
        > {
  @override
  /// Builds the initial own-sent memes page.
  Future<
    PaginatedListState<
      UserDetailsOwnSentMemesListPageItemEntity,
      UserDetailsOwnSentMemesCursorEntity
    >
  >
  build() {
    return buildPaginatedState();
  }

  @override
  /// Loads one own-sent memes page from the list usecase.
  Future<
    PaginatedPage<
      UserDetailsOwnSentMemesListPageItemEntity,
      UserDetailsOwnSentMemesCursorEntity
    >
  >
  loadPage({
    required int limit,
    UserDetailsOwnSentMemesCursorEntity? cursor,
  }) async {
    final ListUserDetailsOwnSentMemesUsecase usecase = ref.watch(
      listUserDetailsOwnSentMemesUsecaseProvider,
    );
    final UserDetailsOwnSentMemesListPageEntity page = await usecase(
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<
      UserDetailsOwnSentMemesListPageItemEntity,
      UserDetailsOwnSentMemesCursorEntity
    >(items: page.items, nextCursor: _cursorFromPage(page));
  }

  /// Refreshes the own-sent memes list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next own-sent memes page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Toggles the current user's laugh state for one listed meme.
  Future<void> toggleMemeLaugh(
    UserDetailsOwnSentMemesListPageItemEntity item,
  ) async {
    final PaginatedListState<
      UserDetailsOwnSentMemesListPageItemEntity,
      UserDetailsOwnSentMemesCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final String memeId = item.meme.id;
    final int index = current.items.indexWhere(
      (UserDetailsOwnSentMemesListPageItemEntity currentItem) =>
          currentItem.meme.id == memeId,
    );
    if (index < 0) {
      return;
    }

    final UserDetailsOwnSentMemesListPageItemEntity currentItem =
        current.items[index];
    final String? currentUserId = ref.read(currentUserProvider)?.id;
    if (currentUserId != null && currentItem.user.id == currentUserId) {
      return;
    }

    final bool wasLaughed = currentItem.meme.isLaughed;
    final int previousCount = currentItem.meme.laughCount;
    final bool nextLaughed = !wasLaughed;
    final int nextCount = nextLaughed
        ? previousCount + 1
        : (previousCount - 1).clamp(0, previousCount).toInt();

    await runOptimisticUpdate<bool>(
      apply:
          (
            PaginatedListState<
              UserDetailsOwnSentMemesListPageItemEntity,
              UserDetailsOwnSentMemesCursorEntity
            >
            state,
          ) {
            return _setMemeLaughState(
              state,
              memeId: memeId,
              isLaughed: nextLaughed,
              laughCount: nextCount,
            );
          },
      rollback:
          (
            PaginatedListState<
              UserDetailsOwnSentMemesListPageItemEntity,
              UserDetailsOwnSentMemesCursorEntity
            >
            state,
          ) {
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

  PaginatedListState<
    UserDetailsOwnSentMemesListPageItemEntity,
    UserDetailsOwnSentMemesCursorEntity
  >
  _setMemeLaughState(
    PaginatedListState<
      UserDetailsOwnSentMemesListPageItemEntity,
      UserDetailsOwnSentMemesCursorEntity
    >
    state, {
    required String memeId,
    required bool isLaughed,
    required int laughCount,
  }) {
    final List<UserDetailsOwnSentMemesListPageItemEntity> nextItems = state
        .items
        .map((UserDetailsOwnSentMemesListPageItemEntity item) {
          if (item.meme.id != memeId) {
            return item;
          }

          return item.copyWith(
            meme: item.meme.copyWith(
              isLaughed: isLaughed,
              laughCount: laughCount,
            ),
          );
        })
        .toList(growable: false);

    return state.copyWith(
      items: List<UserDetailsOwnSentMemesListPageItemEntity>.unmodifiable(
        nextItems,
      ),
    );
  }

  UserDetailsOwnSentMemesCursorEntity? _cursorFromPage(
    UserDetailsOwnSentMemesListPageEntity page,
  ) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return UserDetailsOwnSentMemesCursorEntity(createdAt: createdAt, id: id);
  }
}
