import 'dart:typed_data';

import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_image_size_entity.dart';

/// Repository contract for meme-editor render and export operations.
abstract class MemeEditorRenderRepository {
  /// Resolves source background pixel size from the current editor [state].
  Future<MemeImageSizeEntity> resolveBackgroundSize({
    /// Current editor snapshot.
    required MemeEditorStateEntity state,
  });

  /// Normalizes finalized PNG [bytes] to [targetSize].
  Uint8List normalizeFinalizedImageBytes({
    /// Raw finalized PNG bytes captured from the editor view.
    required Uint8List bytes,

    /// Target output size in pixels.
    required MemeImageSizeEntity targetSize,
  });
}
