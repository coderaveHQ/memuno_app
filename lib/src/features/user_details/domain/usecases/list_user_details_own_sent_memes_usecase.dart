import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Usecase for loading own-sent user-details memes.
final class ListUserDetailsOwnSentMemesUsecase {
  /// Creates the usecase.
  const ListUserDetailsOwnSentMemesUsecase({
    required UserDetailsRepository repository,
  }) : _repository = repository;

  final UserDetailsRepository _repository;

  /// Executes one paginated own-sent memes query.
  Future<UserDetailsOwnSentMemesListPageEntity> call({
    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    UserDetailsOwnSentMemesCursorEntity? cursor,
  }) {
    return _repository.listUserDetailsOwnSentMemes(
      limit: limit,
      cursor: cursor,
    );
  }
}
