import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
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
        AsyncPaginationMixin<MemeItemEntity, ListCursorEntity>,
        OptimisticAsyncStateMixin<
          PaginatedListState<MemeItemEntity, ListCursorEntity>
        > {
  @override
  /// Builds the initial feed page.
  Future<PaginatedListState<MemeItemEntity, ListCursorEntity>> build() {
    return buildPaginatedState();
  }

  @override
  /// Loads one feed page from the list usecase.
  Future<PaginatedPage<MemeItemEntity, ListCursorEntity>> loadPage({
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    final ListFeedUsecase usecase = ref.watch(listFeedUsecaseProvider);
    final FeedListPageEntity page = await usecase(
      limit: limit,
      cursor: cursor == null
          ? null
          : FeedCursorEntity(createdAt: cursor.createdAt, id: cursor.id),
    );

    return PaginatedPage<MemeItemEntity, ListCursorEntity>(
      items: page.items.map(_toMemeItemEntity).toList(growable: false),
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
  Future<void> toggleMemeLaugh(MemeItemEntity feedItem) async {
    final PaginatedListState<MemeItemEntity, ListCursorEntity>? current =
        state.asData?.value;
    if (current == null) {
      return;
    }

    final String memeId = feedItem.id;
    final int index = current.items.indexWhere((MemeItemEntity item) {
      return item.id == memeId;
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
        final ToggleMemeLaughUsecase usecase = ref.read(
          toggleMemeLaughUsecaseProvider,
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

  ListCursorEntity? _cursorFromPage(FeedListPageEntity page) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return ListCursorEntity(createdAt: createdAt, id: id);
  }

  MemeItemEntity _toMemeItemEntity(FeedListPageItemEntity item) {
    return MemeItemEntity(
      id: item.meme.id,
      createdAt: item.meme.createdAt,
      updatedAt: item.meme.updatedAt,
      signedImageUrl: item.meme.signedImageUrl,
      aspectRatio: item.meme.aspectRatio,
      laughCount: item.meme.laughCount,
      isLaughed: item.meme.isLaughed,
      user: UserItemEntity(
        id: item.user.id,
        name: item.user.name,
        friendshipCode: item.user.friendshipCode,
        createdAt: item.user.createdAt,
        updatedAt: item.user.updatedAt,
      ),
    );
  }
}
