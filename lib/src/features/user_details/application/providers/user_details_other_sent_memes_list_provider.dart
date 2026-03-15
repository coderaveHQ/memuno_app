import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/usecases/list_user_details_other_sent_memes_usecase_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/usecases/toggle_user_details_meme_laugh_usecase_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/list_user_details_other_sent_memes_usecase.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/toggle_user_details_meme_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_details_other_sent_memes_list_provider.g.dart';

/// Async paginated controller for other-sent user-details memes.
@Riverpod(keepAlive: true)
class UserDetailsOtherSentMemesList extends _$UserDetailsOtherSentMemesList
    with
        AsyncPaginationMixin<
          UserDetailsOtherSentMemesListPageItemEntity,
          UserDetailsOtherSentMemesCursorEntity
        >,
        OptimisticAsyncStateMixin<
          PaginatedListState<
            UserDetailsOtherSentMemesListPageItemEntity,
            UserDetailsOtherSentMemesCursorEntity
          >
        > {
  @override
  /// Builds the initial other-sent memes page.
  Future<
    PaginatedListState<
      UserDetailsOtherSentMemesListPageItemEntity,
      UserDetailsOtherSentMemesCursorEntity
    >
  >
  build(String userId) {
    return buildPaginatedState();
  }

  @override
  /// Loads one other-sent memes page from the list usecase.
  Future<
    PaginatedPage<
      UserDetailsOtherSentMemesListPageItemEntity,
      UserDetailsOtherSentMemesCursorEntity
    >
  >
  loadPage({
    required int limit,
    UserDetailsOtherSentMemesCursorEntity? cursor,
  }) async {
    final ListUserDetailsOtherSentMemesUsecase usecase = ref.watch(
      listUserDetailsOtherSentMemesUsecaseProvider,
    );
    final UserDetailsOtherSentMemesListPageEntity page = await usecase(
      userId: userId,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<
      UserDetailsOtherSentMemesListPageItemEntity,
      UserDetailsOtherSentMemesCursorEntity
    >(items: page.items, nextCursor: _cursorFromPage(page));
  }

  /// Refreshes the other-sent memes list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next other-sent memes page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Toggles the current user's laugh state for one listed meme.
  Future<void> toggleMemeLaugh(
    UserDetailsOtherSentMemesListPageItemEntity item,
  ) async {
    final PaginatedListState<
      UserDetailsOtherSentMemesListPageItemEntity,
      UserDetailsOtherSentMemesCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final String memeId = item.meme.id;
    final int index = current.items.indexWhere(
      (UserDetailsOtherSentMemesListPageItemEntity currentItem) =>
          currentItem.meme.id == memeId,
    );
    if (index < 0) {
      return;
    }

    final UserDetailsOtherSentMemesListPageItemEntity currentItem =
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
              UserDetailsOtherSentMemesListPageItemEntity,
              UserDetailsOtherSentMemesCursorEntity
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
              UserDetailsOtherSentMemesListPageItemEntity,
              UserDetailsOtherSentMemesCursorEntity
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
    UserDetailsOtherSentMemesListPageItemEntity,
    UserDetailsOtherSentMemesCursorEntity
  >
  _setMemeLaughState(
    PaginatedListState<
      UserDetailsOtherSentMemesListPageItemEntity,
      UserDetailsOtherSentMemesCursorEntity
    >
    state, {
    required String memeId,
    required bool isLaughed,
    required int laughCount,
  }) {
    final List<UserDetailsOtherSentMemesListPageItemEntity> nextItems = state
        .items
        .map((UserDetailsOtherSentMemesListPageItemEntity item) {
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
      items: List<UserDetailsOtherSentMemesListPageItemEntity>.unmodifiable(
        nextItems,
      ),
    );
  }

  UserDetailsOtherSentMemesCursorEntity? _cursorFromPage(
    UserDetailsOtherSentMemesListPageEntity page,
  ) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return UserDetailsOtherSentMemesCursorEntity(createdAt: createdAt, id: id);
  }
}
