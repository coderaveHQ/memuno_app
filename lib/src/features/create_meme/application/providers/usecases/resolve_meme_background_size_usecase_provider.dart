import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_render_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_validator_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_render_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/resolve_meme_background_size_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resolve_meme_background_size_usecase_provider.g.dart';

/// Provides the [ResolveMemeBackgroundSizeUsecase] usecase.
@riverpod
ResolveMemeBackgroundSizeUsecase resolveMemeBackgroundSizeUsecase(Ref ref) {
  final MemeEditorRenderRepository repository = ref.watch(
    memeEditorRenderRepositoryProvider,
  );
  final MemeEditorValidator validator = ref.watch(memeEditorValidatorProvider);

  return ResolveMemeBackgroundSizeUsecase(
    repository: repository,
    validator: validator,
  );
}
