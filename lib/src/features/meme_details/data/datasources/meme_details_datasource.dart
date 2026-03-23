import 'package:memuno_app/src/features/meme_details/data/dto/meme_details_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_recipient_target_item_dto.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_type.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';

/// Low-level datasource for meme details RPC calls.
abstract interface class MemeDetailsDatasource {
  /// Loads details payload for one meme.
  Future<MemeDetailsDto> getMemeDetails({
    /// Meme id to load.
    required String memeId,
  });

  /// Loads one page of laughed users for one meme.
  Future<MemeLaughListPageDto> listMemeLaughs({
    /// Meme id to query laughs for.
    required String memeId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id value for subsequent page fetches.
    String? cursorId,
  });

  /// Loads one page of currently selected recipient targets for one meme.
  Future<ListPageDto<MemeRecipientTargetItemDto>> listMemeRecipients({
    /// Meme id to query recipients for.
    required String memeId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id value for subsequent page fetches.
    String? cursorId,
  });

  /// Loads one page of addable recipient targets for one meme.
  Future<ListPageDto<MemeRecipientTargetItemDto>>
  listMemeAddableRecipientTargets({
    /// Meme id to query addable targets for.
    required String memeId,

    /// Optional search query.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id value for subsequent page fetches.
    String? cursorId,
  });

  /// Adds one or more recipient targets to one meme.
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
