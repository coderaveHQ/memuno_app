import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_validator_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/set_finalized_meme_bytes_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'set_finalized_meme_bytes_usecase_provider.g.dart';

/// Provides the [SetFinalizedMemeBytesUsecase] usecase.
@riverpod
SetFinalizedMemeBytesUsecase setFinalizedMemeBytesUsecase(Ref ref) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );
  final MemeEditorValidator validator = ref.watch(memeEditorValidatorProvider);

  return SetFinalizedMemeBytesUsecase(
    repository: repository,
    validator: validator,
  );
}
