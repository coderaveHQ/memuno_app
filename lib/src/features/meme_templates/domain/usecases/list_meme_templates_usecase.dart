import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/repositories/meme_templates_repository.dart';

/// Usecase for loading paginated meme templates.
final class ListMemeTemplatesUsecase {
  /// Creates the usecase.
  const ListMemeTemplatesUsecase({required MemeTemplatesRepository repository})
    : _repository = repository;

  /// Repository used to execute meme-template reads.
  final MemeTemplatesRepository _repository;

  /// Executes a paginated meme-templates query.
  Future<MemeTemplateListPageEntity> call({
    /// Optional search term applied to template tags.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    MemeTemplateCursorEntity? cursor,
  }) {
    return _repository.listMemeTemplates(
      search: _normalizeSearch(search),
      limit: limit,
      cursor: cursor,
    );
  }

  /// Normalizes optional search input before repository calls.
  String? _normalizeSearch(String? search) {
    final String? trimmed = search?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
