import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/toggle_selected_meme_text_background_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_selected_meme_text_background_usecase_provider.g.dart';

/// Provides the [ToggleSelectedMemeTextBackgroundUsecase] usecase.
@riverpod
ToggleSelectedMemeTextBackgroundUsecase toggleSelectedMemeTextBackgroundUsecase(
  Ref ref,
) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );

  return ToggleSelectedMemeTextBackgroundUsecase(repository: repository);
}
