import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Usecase for loading other-all user-details memes.
final class ListUserDetailsOtherAllMemesUsecase {
  /// Creates the usecase.
  const ListUserDetailsOtherAllMemesUsecase({
    required UserDetailsRepository repository,
  }) : _repository = repository;

  final UserDetailsRepository _repository;

  /// Executes one paginated other-all memes query.
  Future<UserDetailsOtherAllMemesListPageEntity> call({
    /// Target user id used for other-user details pages.
    required String userId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOtherAllMemesCursorEntity? cursor,
  }) {
    return _repository.listUserDetailsOtherAllMemes(
      userId: userId,
      limit: limit,
      cursor: cursor,
    );
  }
}
