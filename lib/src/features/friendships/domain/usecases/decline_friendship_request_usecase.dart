import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';

/// Usecase for declining an incoming friendship request.
final class DeclineFriendshipRequestUsecase {
  /// Creates the usecase.
  const DeclineFriendshipRequestUsecase({
    required FriendshipsRepository repository,
  }) : _repository = repository;

  /// Repository used to execute request decline.
  final FriendshipsRepository _repository;

  /// Declines the pending request.
  Future<void> call({
    /// Pending friendship-request row identifier.
    required String requestId,
  }) {
    return _repository.declineFriendshipRequest(requestId: requestId);
  }
}
