import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/remove_selected_meme_text_layer_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remove_selected_meme_text_layer_usecase_provider.g.dart';

/// Provides the [RemoveSelectedMemeTextLayerUsecase] usecase.
@riverpod
RemoveSelectedMemeTextLayerUsecase removeSelectedMemeTextLayerUsecase(Ref ref) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );
  return RemoveSelectedMemeTextLayerUsecase(repository: repository);
}
