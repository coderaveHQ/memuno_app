import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_editor_validator_provider.g.dart';

/// Provides the meme-editor input validator.
@Riverpod(keepAlive: true)
MemeEditorValidator memeEditorValidator(Ref ref) {
  return const MemeEditorValidator();
}
