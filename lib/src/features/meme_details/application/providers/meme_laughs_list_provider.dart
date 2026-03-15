import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_provider.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/usecases/list_meme_laughs_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/list_meme_laughs_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_laughs_list_provider.g.dart';

/// Async paginated controller for meme-laugh list state.
@Riverpod(keepAlive: true)
class MemeLaughsList extends _$MemeLaughsList
    with
        AsyncPaginationMixin<
          MemeLaughListPageItemEntity,
          MemeLaughCursorEntity
        > {
  @override
  /// Builds the initial meme-laugh page.
  Future<PaginatedListState<MemeLaughListPageItemEntity, MemeLaughCursorEntity>>
  build(String memeId) {
    return buildPaginatedState();
  }

  @override
  /// Loads one meme-laugh page from the list usecase.
  Future<PaginatedPage<MemeLaughListPageItemEntity, MemeLaughCursorEntity>>
  loadPage({required int limit, MemeLaughCursorEntity? cursor}) async {
    final ListMemeLaughsUsecase usecase = ref.watch(
      listMemeLaughsUsecaseProvider,
    );
    final MemeLaughListPageEntity page = await usecase(
      memeId: memeId,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<MemeLaughListPageItemEntity, MemeLaughCursorEntity>(
      items: page.items,
      nextCursor: _cursorFromPage(page),
    );
  }

  /// Refreshes meme details and meme-laugh list from page 1.
  Future<void> refresh() async {
    await ref.read(memeDetailsProvider(memeId).notifier).refresh();
    await refreshPage();
  }

  /// Loads and appends the next meme-laugh page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  MemeLaughCursorEntity? _cursorFromPage(MemeLaughListPageEntity page) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return MemeLaughCursorEntity(createdAt: createdAt, id: id);
  }
}
