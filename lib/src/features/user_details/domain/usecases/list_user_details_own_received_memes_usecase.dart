import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Usecase for loading own-received user-details memes.
final class ListUserDetailsOwnReceivedMemesUsecase {
  /// Creates the usecase.
  const ListUserDetailsOwnReceivedMemesUsecase({
    required UserDetailsRepository repository,
  }) : _repository = repository;

  final UserDetailsRepository _repository;

  /// Executes one paginated own-received memes query.
  Future<UserDetailsOwnReceivedMemesListPageEntity> call({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOwnReceivedMemesCursorEntity? cursor,
  }) {
    return _repository.listUserDetailsOwnReceivedMemes(
      limit: limit,
      cursor: cursor,
    );
  }
}
