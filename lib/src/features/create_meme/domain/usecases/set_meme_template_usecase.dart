import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';

/// Usecase for selecting a meme template for editing.
final class SetMemeTemplateUsecase {
  /// Creates the usecase.
  const SetMemeTemplateUsecase({required MemeEditorRepository repository})
    : _repository = repository;

  /// Repository used for local state transitions.
  final MemeEditorRepository _repository;

  /// Applies [template] and resets local draft state.
  MemeEditorStateEntity call({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,

    /// Template selected by the user.
    required MemeTemplateListPageItemEntity template,
  }) {
    return _repository.setTemplate(state: state, template: template);
  }
}
