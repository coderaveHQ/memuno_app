import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_render_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_validator_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_render_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/normalize_finalized_meme_bytes_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'normalize_finalized_meme_bytes_usecase_provider.g.dart';

/// Provides the [NormalizeFinalizedMemeBytesUsecase] usecase.
@riverpod
NormalizeFinalizedMemeBytesUsecase normalizeFinalizedMemeBytesUsecase(Ref ref) {
  final MemeEditorRenderRepository repository = ref.watch(
    memeEditorRenderRepositoryProvider,
  );
  final MemeEditorValidator validator = ref.watch(memeEditorValidatorProvider);

  return NormalizeFinalizedMemeBytesUsecase(
    repository: repository,
    validator: validator,
  );
}
