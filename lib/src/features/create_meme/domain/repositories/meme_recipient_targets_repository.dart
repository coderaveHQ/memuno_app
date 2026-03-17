import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_recipient_target_item_entity.dart';

/// Repository contract for polymorphic meme recipient targets.
abstract class MemeRecipientTargetsRepository {
  /// Loads one recipient-target list page.
  Future<ListPageEntity<MemeRecipientTargetItemEntity>> listRecipientTargets({
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  });
}
