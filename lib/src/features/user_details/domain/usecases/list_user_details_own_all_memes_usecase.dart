import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Usecase for loading own-all user-details memes.
final class ListUserDetailsOwnAllMemesUsecase {
  /// Creates the usecase.
  const ListUserDetailsOwnAllMemesUsecase({
    required UserDetailsRepository repository,
  }) : _repository = repository;

  final UserDetailsRepository _repository;

  /// Executes one paginated own-all memes query.
  Future<UserDetailsOwnAllMemesListPageEntity> call({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOwnAllMemesCursorEntity? cursor,
  }) {
    return _repository.listUserDetailsOwnAllMemes(limit: limit, cursor: cursor);
  }
}
