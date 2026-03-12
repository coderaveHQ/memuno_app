import 'dart:typed_data';

import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_image_size_entity.dart';

/// Datasource contract for local meme-editor render operations.
abstract class MemeEditorRenderDatasource {
  /// Resolves source background pixel size from editor [state].
  Future<MemeImageSizeEntity> resolveBackgroundSize({
    required MemeEditorStateEntity state,
  });

  /// Normalizes finalized PNG [bytes] to [targetSize].
  Uint8List normalizeFinalizedImageBytes({
    required Uint8List bytes,
    required MemeImageSizeEntity targetSize,
  });
}
