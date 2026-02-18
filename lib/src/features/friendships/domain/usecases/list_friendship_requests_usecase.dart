import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';

/// Usecase for loading paginated friendship requests.
final class ListFriendshipRequestsUsecase {
  /// Creates the usecase.
  const ListFriendshipRequestsUsecase({
    required FriendshipsRepository repository,
  }) : _repository = repository;

  /// Repository used to execute friendship-request reads.
  final FriendshipsRepository _repository;

  /// Executes a paginated friendship-requests query.
  Future<PaginatedPage<FriendshipRequestEntity, FriendshipRequestCursorEntity>>
  call({
    /// Optional search term applied to user name/code.
    String? search,

    /// Requested backend page size.
    required int limit,

    /// Optional cursor for requesting a subsequent page.
    FriendshipRequestCursorEntity? cursor,
  }) {
    return _repository.listFriendshipRequests(
      search: search,
      limit: limit,
      cursor: cursor,
    );
  }
}
