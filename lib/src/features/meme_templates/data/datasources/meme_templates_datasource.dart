import 'package:memuno_app/src/features/meme_templates/data/dto/meme_templates_page_dto.dart';

/// Datasource contract for meme-template RPC and storage operations.
abstract interface class MemeTemplatesDatasource {
  /// Loads one page from `meme_templates_list` RPC.
  Future<MemeTemplatesPageDto> listMemeTemplates({
    /// Optional search term applied server-side.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional creation timestamp cursor.
    DateTime? cursorCreatedAt,

    /// Optional id cursor used as a stable tie-breaker.
    String? cursorId,
  });
}
