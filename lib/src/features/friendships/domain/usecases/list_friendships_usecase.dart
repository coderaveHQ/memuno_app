import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';

/// Usecase for loading paginated friendships.
final class ListFriendshipsUsecase {
  /// Creates the usecase.
  const ListFriendshipsUsecase({required FriendshipsRepository repository})
    : _repository = repository;

  /// Repository used to execute friendship reads.
  final FriendshipsRepository _repository;

  /// Executes one friendship-list page query.
  Future<FriendshipListPageEntity> call({
    /// Optional search term applied to friend name/code.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    FriendshipCursorEntity? cursor,
  }) {
    return _repository.listFriendships(
      search: search,
      limit: limit,
      cursor: cursor,
    );
  }
}
