import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';

/// Usecase for canceling an outgoing friendship request.
final class CancelFriendshipRequestUsecase {
  /// Creates the usecase.
  const CancelFriendshipRequestUsecase({
    required FriendshipsRepository repository,
  }) : _repository = repository;

  /// Repository used to execute request cancellation.
  final FriendshipsRepository _repository;

  /// Cancels the pending outgoing request.
  Future<void> call({
    /// Pending friendship-request row identifier.
    required String requestId,
  }) {
    return _repository.cancelFriendshipRequest(requestId: requestId);
  }
}
