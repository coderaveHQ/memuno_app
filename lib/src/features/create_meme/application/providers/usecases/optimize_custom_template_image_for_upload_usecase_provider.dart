import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_validator_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/optimize_custom_template_image_for_upload_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'optimize_custom_template_image_for_upload_usecase_provider.g.dart';

/// Provides [OptimizeCustomTemplateImageForUploadUsecase].
@riverpod
OptimizeCustomTemplateImageForUploadUsecase
optimizeCustomTemplateImageForUploadUsecase(Ref ref) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );
  final MemeEditorValidator validator = ref.watch(memeEditorValidatorProvider);
  return OptimizeCustomTemplateImageForUploadUsecase(
    repository: repository,
    validator: validator,
  );
}
