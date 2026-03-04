import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/meme_templates/application/providers/usecases/list_meme_templates_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/usecases/list_meme_templates_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_templates_list_provider.g.dart';

/// Async paginated controller for active meme templates.
@Riverpod(keepAlive: true)
class MemeTemplatesList extends _$MemeTemplatesList
    with
        AsyncPaginationMixin<
          MemeTemplateListPageItemEntity,
          MemeTemplateCursorEntity
        >,
        AsyncPaginationSearchMixin<
          MemeTemplateListPageItemEntity,
          MemeTemplateCursorEntity
        > {
  @override
  /// Builds the initial meme-templates page.
  Future<
    PaginatedListState<MemeTemplateListPageItemEntity, MemeTemplateCursorEntity>
  >
  build() {
    return buildSearchPaginatedState();
  }

  @override
  /// Loads one meme-templates page from the list usecase.
  Future<
    PaginatedPage<MemeTemplateListPageItemEntity, MemeTemplateCursorEntity>
  >
  loadPage({required int limit, MemeTemplateCursorEntity? cursor}) async {
    final ListMemeTemplatesUsecase usecase = ref.watch(
      listMemeTemplatesUsecaseProvider,
    );
    final MemeTemplateListPageEntity page = await usecase(
      search: searchQuery,
      limit: limit,
      cursor: cursor,
    );
    return PaginatedPage<
      MemeTemplateListPageItemEntity,
      MemeTemplateCursorEntity
    >(items: page.items, nextCursor: _cursorFromPage(page));
  }

  /// Refreshes the meme-templates list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next meme-templates page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  MemeTemplateCursorEntity? _cursorFromPage(MemeTemplateListPageEntity page) {
    final DateTime? nextCursorCreatedAt = page.nextCursorCreatedAt;
    final String? nextCursorId = page.nextCursorId;
    if (nextCursorCreatedAt == null || nextCursorId == null) {
      return null;
    }

    return MemeTemplateCursorEntity(
      createdAt: nextCursorCreatedAt,
      id: nextCursorId,
    );
  }
}
