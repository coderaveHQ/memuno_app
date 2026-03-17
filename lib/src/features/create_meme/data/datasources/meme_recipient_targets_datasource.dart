import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/features/create_meme/data/dto/meme_recipient_target_item_dto.dart';

/// Datasource contract for polymorphic recipient-target list operations.
abstract class MemeRecipientTargetsDatasource {
  /// Loads one recipient-target page from backend RPC.
  Future<ListPageDto<MemeRecipientTargetItemDto>> listRecipientTargets({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  });
}
