import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_entity.dart';

/// Contract for user-details operations.
abstract interface class UserDetailsRepository {
  /// Loads one user's details information.
  Future<UserDetailsEntity> getUserDetails({required String userId});

  /// Updates the current user's name.
  Future<void> updateCurrentUserDetailsName({required String name});

  /// Loads one own-all user-details memes page.
  Future<UserDetailsOwnAllMemesListPageEntity> listUserDetailsOwnAllMemes({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOwnAllMemesCursorEntity? cursor,
  });

  /// Loads one own-sent user-details memes page.
  Future<UserDetailsOwnSentMemesListPageEntity> listUserDetailsOwnSentMemes({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOwnSentMemesCursorEntity? cursor,
  });

  /// Loads one own-received user-details memes page.
  Future<UserDetailsOwnReceivedMemesListPageEntity>
  listUserDetailsOwnReceivedMemes({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOwnReceivedMemesCursorEntity? cursor,
  });

  /// Loads one other-all user-details memes page.
  Future<UserDetailsOtherAllMemesListPageEntity> listUserDetailsOtherAllMemes({
    /// Target user id used for the viewed user-details page.
    required String userId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOtherAllMemesCursorEntity? cursor,
  });

  /// Loads one other-sent user-details memes page.
  Future<UserDetailsOtherSentMemesListPageEntity>
  listUserDetailsOtherSentMemes({
    /// Target user id used for the viewed user-details page.
    required String userId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOtherSentMemesCursorEntity? cursor,
  });

  /// Loads one other-received user-details memes page.
  Future<UserDetailsOtherReceivedMemesListPageEntity>
  listUserDetailsOtherReceivedMemes({
    /// Target user id used for the viewed user-details page.
    required String userId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOtherReceivedMemesCursorEntity? cursor,
  });

  /// Toggles one meme laugh and returns the resulting liked-state.
  Future<bool> toggleUserDetailsMemeLaugh({
    /// Meme id to like or unlike.
    required String memeId,
  });
}
