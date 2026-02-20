import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for toggling recipient selection for the send-meme flow.
final class ToggleMemeRecipientSelectionUsecase {
  /// Creates the usecase.
  const ToggleMemeRecipientSelectionUsecase({
    required MemeEditorRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Validator used for input checks.
  final MemeEditorValidator _validator;

  /// Toggles selection state for one friendship [userId].
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Friendship-user identifier to toggle.
    required String userId,
  }) {
    final Failure? validation = _validator.validateFriendUserId(userId);
    if (validation != null) {
      throw validation;
    }

    return _repository.toggleRecipientSelection(state: state, userId: userId);
  }
}
