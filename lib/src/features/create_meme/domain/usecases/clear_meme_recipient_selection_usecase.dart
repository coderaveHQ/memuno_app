import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';

/// Usecase for clearing all selected recipients in send-meme flow.
final class ClearMemeRecipientSelectionUsecase {
  /// Creates the usecase.
  const ClearMemeRecipientSelectionUsecase({
    required MemeEditorRepository repository,
  }) : _repository = repository;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Clears all selected recipients.
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,
  }) {
    return _repository.clearRecipientSelection(state: state);
  }
}
