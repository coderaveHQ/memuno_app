import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/usecases/list_meme_addable_recipient_targets_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/list_meme_addable_recipient_targets_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_addable_recipient_targets_list_provider.g.dart';

/// Async paginated controller for one meme's addable recipient-target list.
@Riverpod(keepAlive: true)
class MemeAddableRecipientTargetsList extends _$MemeAddableRecipientTargetsList
    with
        AsyncPaginationMixin<MemeRecipientTargetItemEntity, ListCursorEntity>,
        AsyncPaginationSearchMixin<
          MemeRecipientTargetItemEntity,
          ListCursorEntity
        > {
  @override
  Future<PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>>
  build(String memeId) {
    return buildSearchPaginatedState();
  }

  @override
  Future<PaginatedPage<MemeRecipientTargetItemEntity, ListCursorEntity>>
  loadPage({required int limit, ListCursorEntity? cursor}) async {
    final ListMemeAddableRecipientTargetsUsecase usecase = ref.watch(
      listMemeAddableRecipientTargetsUsecaseProvider,
    );

    final ListPageEntity<MemeRecipientTargetItemEntity> page = await usecase(
      memeId: memeId,
      search: searchQuery,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<MemeRecipientTargetItemEntity, ListCursorEntity>(
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

  ListCursorEntity? _cursorFromPage(
    ListPageEntity<MemeRecipientTargetItemEntity> page,
  ) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return ListCursorEntity(createdAt: createdAt, id: id);
  }
}
