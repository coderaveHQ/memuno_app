import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_validator_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/set_custom_meme_template_image_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'set_custom_meme_template_image_usecase_provider.g.dart';

/// Provides the [SetCustomMemeTemplateImageUsecase] usecase.
@riverpod
SetCustomMemeTemplateImageUsecase setCustomMemeTemplateImageUsecase(Ref ref) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );
  final MemeEditorValidator validator = ref.watch(memeEditorValidatorProvider);
  return SetCustomMemeTemplateImageUsecase(
    repository: repository,
    validator: validator,
  );
}
