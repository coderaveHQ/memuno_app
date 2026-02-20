import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_validator_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/update_selected_meme_text_font_size_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'update_selected_meme_text_font_size_usecase_provider.g.dart';

/// Provides the [UpdateSelectedMemeTextFontSizeUsecase] usecase.
@riverpod
UpdateSelectedMemeTextFontSizeUsecase updateSelectedMemeTextFontSizeUsecase(
  Ref ref,
) {
  final MemeEditorRepository repository = ref.watch(
    memeEditorRepositoryProvider,
  );
  final MemeEditorValidator validator = ref.watch(memeEditorValidatorProvider);

  return UpdateSelectedMemeTextFontSizeUsecase(
    repository: repository,
    validator: validator,
  );
}
