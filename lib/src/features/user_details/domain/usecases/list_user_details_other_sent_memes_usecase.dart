import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Usecase for loading other-sent user-details memes.
final class ListUserDetailsOtherSentMemesUsecase {
  /// Creates the usecase.
  const ListUserDetailsOtherSentMemesUsecase({
    required UserDetailsRepository repository,
  }) : _repository = repository;

  final UserDetailsRepository _repository;

  /// Executes one paginated other-sent memes query.
  Future<UserDetailsOtherSentMemesListPageEntity> call({
    /// Target user id used for other-user details pages.
    required String userId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOtherSentMemesCursorEntity? cursor,
  }) {
    return _repository.listUserDetailsOtherSentMemes(
      userId: userId,
      limit: limit,
      cursor: cursor,
    );
  }
}
