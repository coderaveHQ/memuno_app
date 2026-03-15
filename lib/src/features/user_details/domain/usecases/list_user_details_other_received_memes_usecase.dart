import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Usecase for loading other-received user-details memes.
final class ListUserDetailsOtherReceivedMemesUsecase {
  /// Creates the usecase.
  const ListUserDetailsOtherReceivedMemesUsecase({
    required UserDetailsRepository repository,
  }) : _repository = repository;

  final UserDetailsRepository _repository;

  /// Executes one paginated other-received memes query.
  Future<UserDetailsOtherReceivedMemesListPageEntity> call({
    /// Target user id used for other-user details pages.
    required String userId,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOtherReceivedMemesCursorEntity? cursor,
  }) {
    return _repository.listUserDetailsOtherReceivedMemes(
      userId: userId,
      limit: limit,
      cursor: cursor,
    );
  }
}
