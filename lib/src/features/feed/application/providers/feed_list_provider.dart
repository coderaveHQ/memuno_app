import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/feed/application/providers/usecases/list_feed_usecase_provider.dart';
import 'package:memuno_app/src/features/feed/application/providers/usecases/toggle_meme_laugh_usecase_provider.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_cursor_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_item_entity.dart';
import 'package:memuno_app/src/features/feed/domain/usecases/list_feed_usecase.dart';
import 'package:memuno_app/src/features/feed/domain/usecases/toggle_meme_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_list_provider.g.dart';

/// Async paginated controller for feed list state.
@Riverpod(keepAlive: true)
class FeedList extends _$FeedList
    with
        AsyncPaginationMixin<FeedListPageItemEntity, FeedCursorEntity>,
        OptimisticAsyncStateMixin<
          PaginatedListState<FeedListPageItemEntity, FeedCursorEntity>
        > {
  @override
  /// Builds the initial feed page.
  Future<PaginatedListState<FeedListPageItemEntity, FeedCursorEntity>> build() {
    return buildPaginatedState();
  }

  @override
  /// Loads one feed page from the list usecase.
  Future<PaginatedPage<FeedListPageItemEntity, FeedCursorEntity>> loadPage({
    required int limit,
    FeedCursorEntity? cursor,
  }) async {
    final ListFeedUsecase usecase = ref.watch(listFeedUsecaseProvider);
    final FeedListPageEntity page = await usecase(limit: limit, cursor: cursor);

    return PaginatedPage<FeedListPageItemEntity, FeedCursorEntity>(
      items: page.items,
      nextCursor: _cursorFromPage(page),
    );
  }

  /// Refreshes the feed list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next feed page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Toggles the current user's laugh state for one feed meme.
  Future<void> toggleMemeLaugh(FeedListPageItemEntity feedItem) async {
    final PaginatedListState<FeedListPageItemEntity, FeedCursorEntity>?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final String memeId = feedItem.meme.id;
    final int index = current.items.indexWhere(
      (FeedListPageItemEntity item) => item.meme.id == memeId,
    );
    if (index < 0) {
      return;
    }
    final FeedListPageItemEntity currentItem = current.items[index];
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
          (PaginatedListState<FeedListPageItemEntity, FeedCursorEntity> state) {
            return _setMemeLaughState(
              state,
              memeId: memeId,
              isLaughed: nextLaughed,
              laughCount: nextCount,
            );
          },
      rollback:
          (PaginatedListState<FeedListPageItemEntity, FeedCursorEntity> state) {
            return _setMemeLaughState(
              state,
              memeId: memeId,
              isLaughed: wasLaughed,
              laughCount: previousCount,
            );
          },
      operation: () {
        final ToggleMemeLaughUsecase usecase = ref.read(
          toggleMemeLaughUsecaseProvider,
        );
        return usecase(memeId: memeId);
      },
    );
  }

  PaginatedListState<FeedListPageItemEntity, FeedCursorEntity>
  _setMemeLaughState(
    PaginatedListState<FeedListPageItemEntity, FeedCursorEntity> state, {
    required String memeId,
    required bool isLaughed,
    required int laughCount,
  }) {
    final List<FeedListPageItemEntity> nextItems = state.items
        .map((FeedListPageItemEntity item) {
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
      items: List<FeedListPageItemEntity>.unmodifiable(nextItems),
    );
  }

  FeedCursorEntity? _cursorFromPage(FeedListPageEntity page) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return FeedCursorEntity(createdAt: createdAt, id: id);
  }
}
