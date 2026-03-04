import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';

/// Usecase for creating a new friendship request.
final class CreateFriendshipRequestUsecase {
  /// Creates the usecase.
  const CreateFriendshipRequestUsecase({
    required FriendshipsRepository repository,
    required Validator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used to execute request creation.
  final FriendshipsRepository _repository;

  /// Validator used for local friendship-code checks.
  final Validator _validator;

  /// Creates a friendship request addressed by [addresseeFriendshipCode].
  Future<FriendshipRequestListPageItemEntity> call({
    /// Friendship code entered in the add-friend dialog.
    required String addresseeFriendshipCode,
  }) {
    final Failure? friendshipCodeFailure = _validator.validateFriendshipCode(
      addresseeFriendshipCode,
    );
    if (friendshipCodeFailure != null) {
      throw friendshipCodeFailure;
    }

    return _repository.createFriendshipRequest(
      addresseeFriendshipCode: addresseeFriendshipCode,
    );
  }
}
