import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/list_meme_recipient_targets_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/list_meme_recipient_targets_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_recipient_targets_list_provider.g.dart';

/// Async paginated controller for polymorphic recipient targets list state.
@Riverpod(keepAlive: true)
class MemeRecipientTargetsList extends _$MemeRecipientTargetsList
    with
        AsyncPaginationMixin<MemeRecipientTargetItemEntity, ListCursorEntity>,
        AsyncPaginationSearchMixin<
          MemeRecipientTargetItemEntity,
          ListCursorEntity
        > {
  @override
  Future<PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>>
  build() {
    return buildSearchPaginatedState();
  }

  @override
  Future<PaginatedPage<MemeRecipientTargetItemEntity, ListCursorEntity>>
  loadPage({required int limit, ListCursorEntity? cursor}) async {
    final ListMemeRecipientTargetsUsecase usecase = ref.watch(
      listMemeRecipientTargetsUsecaseProvider,
    );

    final ListPageEntity<MemeRecipientTargetItemEntity> page = await usecase(
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

  /// Loads and appends the next recipient-target page.
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
