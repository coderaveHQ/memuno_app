import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_editor_render_datasource.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_image_size_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_render_repository.dart';

/// Repository implementation for local meme-render operations.
final class MemeEditorRenderRepositoryImpl
    implements MemeEditorRenderRepository {
  /// Creates the repository.
  const MemeEditorRenderRepositoryImpl({
    required MemeEditorRenderDatasource memeEditorRenderDatasource,
    required FailureMapper failureMapper,
  }) : _memeEditorRenderDatasource = memeEditorRenderDatasource,
       _failureMapper = failureMapper;

  /// Datasource used for image-size resolution and byte normalization.
  final MemeEditorRenderDatasource _memeEditorRenderDatasource;

  /// Mapper used to normalize thrown errors into failures.
  final FailureMapper _failureMapper;

  @override
  Future<MemeImageSizeEntity> resolveBackgroundSize({
    required MemeEditorStateEntity state,
  }) async {
    try {
      return await _memeEditorRenderDatasource.resolveBackgroundSize(
        state: state,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Uint8List normalizeFinalizedImageBytes({
    required Uint8List bytes,
    required MemeImageSizeEntity targetSize,
  }) {
    try {
      return _memeEditorRenderDatasource.normalizeFinalizedImageBytes(
        bytes: bytes,
        targetSize: targetSize,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
