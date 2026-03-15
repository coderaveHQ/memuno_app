import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/usecases/list_user_details_own_all_memes_usecase_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/usecases/toggle_user_details_meme_laugh_usecase_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/list_user_details_own_all_memes_usecase.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/toggle_user_details_meme_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_details_own_all_memes_list_provider.g.dart';

/// Async paginated controller for own-all user-details memes.
@Riverpod(keepAlive: true)
class UserDetailsOwnAllMemesList extends _$UserDetailsOwnAllMemesList
    with
        AsyncPaginationMixin<
          UserDetailsOwnAllMemesListPageItemEntity,
          UserDetailsOwnAllMemesCursorEntity
        >,
        OptimisticAsyncStateMixin<
          PaginatedListState<
            UserDetailsOwnAllMemesListPageItemEntity,
            UserDetailsOwnAllMemesCursorEntity
          >
        > {
  @override
  /// Builds the initial own-all memes page.
  Future<
    PaginatedListState<
      UserDetailsOwnAllMemesListPageItemEntity,
      UserDetailsOwnAllMemesCursorEntity
    >
  >
  build() {
    return buildPaginatedState();
  }

  @override
  /// Loads one own-all memes page from the list usecase.
  Future<
    PaginatedPage<
      UserDetailsOwnAllMemesListPageItemEntity,
      UserDetailsOwnAllMemesCursorEntity
    >
  >
  loadPage({
    required int limit,
    UserDetailsOwnAllMemesCursorEntity? cursor,
  }) async {
    final ListUserDetailsOwnAllMemesUsecase usecase = ref.watch(
      listUserDetailsOwnAllMemesUsecaseProvider,
    );
    final UserDetailsOwnAllMemesListPageEntity page = await usecase(
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<
      UserDetailsOwnAllMemesListPageItemEntity,
      UserDetailsOwnAllMemesCursorEntity
    >(items: page.items, nextCursor: _cursorFromPage(page));
  }

  /// Refreshes the own-all memes list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next own-all memes page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Toggles the current user's laugh state for one listed meme.
  Future<void> toggleMemeLaugh(
    UserDetailsOwnAllMemesListPageItemEntity item,
  ) async {
    final PaginatedListState<
      UserDetailsOwnAllMemesListPageItemEntity,
      UserDetailsOwnAllMemesCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final String memeId = item.meme.id;
    final int index = current.items.indexWhere(
      (UserDetailsOwnAllMemesListPageItemEntity currentItem) =>
          currentItem.meme.id == memeId,
    );
    if (index < 0) {
      return;
    }

    final UserDetailsOwnAllMemesListPageItemEntity currentItem =
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
              UserDetailsOwnAllMemesListPageItemEntity,
              UserDetailsOwnAllMemesCursorEntity
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
              UserDetailsOwnAllMemesListPageItemEntity,
              UserDetailsOwnAllMemesCursorEntity
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
    UserDetailsOwnAllMemesListPageItemEntity,
    UserDetailsOwnAllMemesCursorEntity
  >
  _setMemeLaughState(
    PaginatedListState<
      UserDetailsOwnAllMemesListPageItemEntity,
      UserDetailsOwnAllMemesCursorEntity
    >
    state, {
    required String memeId,
    required bool isLaughed,
    required int laughCount,
  }) {
    final List<UserDetailsOwnAllMemesListPageItemEntity> nextItems = state.items
        .map((UserDetailsOwnAllMemesListPageItemEntity item) {
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
      items: List<UserDetailsOwnAllMemesListPageItemEntity>.unmodifiable(
        nextItems,
      ),
    );
  }

  UserDetailsOwnAllMemesCursorEntity? _cursorFromPage(
    UserDetailsOwnAllMemesListPageEntity page,
  ) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return UserDetailsOwnAllMemesCursorEntity(createdAt: createdAt, id: id);
  }
}
