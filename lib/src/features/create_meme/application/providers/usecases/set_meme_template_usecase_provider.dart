import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/set_meme_template_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'set_meme_template_usecase_provider.g.dart';

/// Provides the [SetMemeTemplateUsecase] usecase.
@riverpod
SetMemeTemplateUsecase setMemeTemplateUsecase(Ref ref) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );
  return SetMemeTemplateUsecase(repository: repository);
}
