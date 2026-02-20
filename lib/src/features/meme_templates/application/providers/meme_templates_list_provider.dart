import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/meme_templates/application/providers/usecases/list_meme_templates_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/usecases/list_meme_templates_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_templates_list_provider.g.dart';

/// Async paginated controller for active meme templates.
@Riverpod(keepAlive: true)
class MemeTemplatesList extends _$MemeTemplatesList
    with
        AsyncPaginationMixin<MemeTemplateEntity, MemeTemplateCursorEntity>,
        AsyncPaginationSearchMixin<
          MemeTemplateEntity,
          MemeTemplateCursorEntity
        > {
  @override
  /// Builds the initial meme-templates page.
  Future<PaginatedListState<MemeTemplateEntity, MemeTemplateCursorEntity>>
  build() {
    return buildSearchPaginatedState();
  }

  @override
  /// Loads one meme-templates page from the list usecase.
  Future<PaginatedPage<MemeTemplateEntity, MemeTemplateCursorEntity>> loadPage({
    required int limit,
    MemeTemplateCursorEntity? cursor,
  }) async {
    final ListMemeTemplatesUsecase usecase = ref.watch(
      listMemeTemplatesUsecaseProvider,
    );
    return usecase(search: searchQuery, limit: limit, cursor: cursor);
  }

  /// Refreshes the meme-templates list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next meme-templates page.
  Future<void> loadMore() {
    return loadNextPage();
  }
}
