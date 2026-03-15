import 'package:memuno_app/src/features/user_details/data/dto/user_details_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_sent_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_dto.dart';

/// Low-level datasource for user-details data operations.
abstract interface class UserDetailsDatasource {
  /// Loads one user-details row by user id.
  Future<UserDetailsDto> getUserDetails({required String userId});

  /// Updates the current user's name through an RPC call.
  Future<void> updateCurrentUserDetailsName({required String name});

  /// Loads one page from the own-all user-details memes RPC.
  Future<UserDetailsOwnAllMemesListPageDto> listUserDetailsOwnAllMemes({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Loads one page from the own-sent user-details memes RPC.
  Future<UserDetailsOwnSentMemesListPageDto> listUserDetailsOwnSentMemes({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Loads one page from the own-received user-details memes RPC.
  Future<UserDetailsOwnReceivedMemesListPageDto>
  listUserDetailsOwnReceivedMemes({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Loads one page from the other-all user-details memes RPC.
  Future<UserDetailsOtherAllMemesListPageDto> listUserDetailsOtherAllMemes({
    /// User id for the viewed user-details page.
    required String userId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Loads one page from the other-sent user-details memes RPC.
  Future<UserDetailsOtherSentMemesListPageDto> listUserDetailsOtherSentMemes({
    /// User id for the viewed user-details page.
    required String userId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Loads one page from the other-received user-details memes RPC.
  Future<UserDetailsOtherReceivedMemesListPageDto>
  listUserDetailsOtherReceivedMemes({
    /// User id for the viewed user-details page.
    required String userId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor created-at value for subsequent page fetches.
    DateTime? cursorCreatedAt,

    /// Optional cursor id for subsequent page fetches.
    String? cursorId,
  });

  /// Toggles the current user's laugh state for one meme.
  Future<bool> toggleUserDetailsMemeLaugh({
    /// Meme id to like or unlike.
    required String memeId,
  });
}
