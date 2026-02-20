import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';

/// Repository contract for meme-template read operations.
abstract interface class MemeTemplatesRepository {
  /// Loads one paginated meme-templates page.
  Future<PaginatedPage<MemeTemplateEntity, MemeTemplateCursorEntity>>
  listMemeTemplates({
    /// Optional search term applied to template tags.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    MemeTemplateCursorEntity? cursor,
  });
}
