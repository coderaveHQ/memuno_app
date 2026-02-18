import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';

/// Usecase for deleting an existing friendship.
final class DeleteFriendshipUsecase {
  /// Creates the usecase.
  const DeleteFriendshipUsecase({required FriendshipsRepository repository})
    : _repository = repository;

  /// Repository used to execute friendship deletion.
  final FriendshipsRepository _repository;

  /// Deletes friendship relation with [friendId].
  Future<void> call({
    /// User id of the friend that should be removed.
    required String friendId,
  }) {
    return _repository.deleteFriendship(friendId: friendId);
  }
}
