import 'package:memuno_app/src/features/meme_templates/application/providers/meme_template_gallery_repository_provider.dart';
import 'package:memuno_app/src/features/meme_templates/domain/repositories/meme_template_gallery_repository.dart';
import 'package:memuno_app/src/features/meme_templates/domain/usecases/pick_and_crop_meme_template_image_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pick_and_crop_meme_template_image_usecase_provider.g.dart';

/// Provides [PickAndCropMemeTemplateImageUsecase].
@riverpod
PickAndCropMemeTemplateImageUsecase pickAndCropMemeTemplateImageUsecase(
  Ref ref,
) {
  final MemeTemplateGalleryRepository repository = ref.watch(
    memeTemplateGalleryRepositoryProvider,
  );
  return PickAndCropMemeTemplateImageUsecase(repository: repository);
}
