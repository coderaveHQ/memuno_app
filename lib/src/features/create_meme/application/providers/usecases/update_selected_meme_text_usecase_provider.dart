import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/update_selected_meme_text_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_selected_meme_text_usecase_provider.g.dart';

/// Provides the [UpdateSelectedMemeTextUsecase] usecase.
@riverpod
UpdateSelectedMemeTextUsecase updateSelectedMemeTextUsecase(Ref ref) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );
  return UpdateSelectedMemeTextUsecase(repository: repository);
}
