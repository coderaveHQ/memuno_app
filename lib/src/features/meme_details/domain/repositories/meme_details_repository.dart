import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_type.dart';

/// Repository contract for meme details and laughs operations.
abstract interface class MemeDetailsRepository {
  /// Loads meme details for one [memeId].
  Future<MemeDetailsEntity> getMemeDetails({
    /// Meme id to load.
    required String memeId,
  });

  /// Loads one paginated page of meme laughs for [memeId].
  Future<MemeLaughListPageEntity> listMemeLaughs({
    /// Meme id to query laughs for.
    required String memeId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    MemeLaughCursorEntity? cursor,
  });

  /// Loads one paginated page of current recipient targets for [memeId].
  Future<ListPageEntity<MemeRecipientTargetItemEntity>> listMemeRecipients({
    /// Meme id to query recipients for.
    required String memeId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    ListCursorEntity? cursor,
  });

  /// Loads one paginated page of addable recipient targets for [memeId].
  Future<ListPageEntity<MemeRecipientTargetItemEntity>>
  listMemeAddableRecipientTargets({
    /// Meme id to query addable recipients for.
    required String memeId,

    /// Optional search query.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    ListCursorEntity? cursor,
  });

  /// Adds one or more recipients to one meme.
  Future<void> addMemeRecipients({
    /// Meme id to update.
    required String memeId,

    /// Direct user recipients to add.
    required List<String> recipientUserIds,

    /// Group recipients to add.
    required List<String> recipientGroupIds,
  });

  /// Removes one recipient target from one meme.
  ///
  /// Returns true when the removed target was the last one and the meme was
  /// deleted by DB trigger.
  Future<bool> removeMemeRecipient({
    /// Meme id to update.
    required String memeId,

    /// Recipient target type.
    required MemeRecipientTargetType targetType,

    /// Recipient target id.
    required String targetId,
  });

  /// Toggles the current user's laugh state for one meme.
  Future<bool> toggleMemeLaugh({
    /// Meme id to like/unlike.
    required String memeId,
  });

  /// Deletes one meme owned by the current user.
  Future<void> deleteMeme({
    /// Meme id to delete.
    required String memeId,
  });
}
