import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_validator_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/toggle_meme_recipient_selection_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_meme_recipient_selection_usecase_provider.g.dart';

/// Provides the [ToggleMemeRecipientSelectionUsecase] usecase.
@riverpod
ToggleMemeRecipientSelectionUsecase toggleMemeRecipientSelectionUsecase(
  Ref ref,
) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );
  final MemeEditorValidator validator = ref.watch(memeEditorValidatorProvider);

  return ToggleMemeRecipientSelectionUsecase(
    repository: repository,
    validator: validator,
  );
}
