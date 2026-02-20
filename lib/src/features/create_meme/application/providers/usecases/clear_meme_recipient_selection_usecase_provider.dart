import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/clear_meme_recipient_selection_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clear_meme_recipient_selection_usecase_provider.g.dart';

/// Provides the [ClearMemeRecipientSelectionUsecase] usecase.
@riverpod
ClearMemeRecipientSelectionUsecase clearMemeRecipientSelectionUsecase(Ref ref) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );

  return ClearMemeRecipientSelectionUsecase(repository: repository);
}
