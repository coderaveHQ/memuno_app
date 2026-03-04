import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';

/// Usecase for accepting an incoming friendship request.
final class AcceptFriendshipRequestUsecase {
  /// Creates the usecase.
  const AcceptFriendshipRequestUsecase({
    required FriendshipsRepository repository,
  }) : _repository = repository;

  /// Repository used to execute request acceptance.
  final FriendshipsRepository _repository;

  /// Accepts the request and returns the created friendship.
  Future<FriendshipListPageItemEntity> call({
    /// Pending friendship-request row identifier.
    required String requestId,
  }) {
    return _repository.acceptFriendshipRequest(requestId: requestId);
  }
}
