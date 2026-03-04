import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_editor_datasource.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';

/// Repository implementation for local meme-editor operations.
final class MemeEditorRepositoryImpl implements MemeEditorRepository {
  /// Creates the repository.
  const MemeEditorRepositoryImpl({
    required MemeEditorDatasource memeEditorDatasource,
    required FailureMapper failureMapper,
  }) : _memeEditorDatasource = memeEditorDatasource,
       _failureMapper = failureMapper;

  /// Datasource used for local editor state transitions.
  final MemeEditorDatasource _memeEditorDatasource;

  /// Mapper used to normalize thrown errors into failures.
  final FailureMapper _failureMapper;

  @override
  MemeEditorStateEntity setTemplate({
    required MemeEditorStateEntity state,
    required MemeTemplateListPageItemEntity template,
  }) {
    try {
      return _memeEditorDatasource.setTemplate(
        state: state,
        template: template,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity setCustomTemplateImage({
    required MemeEditorStateEntity state,
    required Uint8List imageBytes,
    required double aspectRatio,
  }) {
    try {
      return _memeEditorDatasource.setCustomTemplateImage(
        state: state,
        imageBytes: imageBytes,
        aspectRatio: aspectRatio,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity addTextLayer({
    required MemeEditorStateEntity state,
    required String initialText,
  }) {
    try {
      return _memeEditorDatasource.addTextLayer(
        state: state,
        initialText: initialText,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity selectTextLayer({
    required MemeEditorStateEntity state,
    required String? layerId,
  }) {
    try {
      return _memeEditorDatasource.selectTextLayer(
        state: state,
        layerId: layerId,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity updateSelectedText({
    required MemeEditorStateEntity state,
    required String text,
  }) {
    try {
      return _memeEditorDatasource.updateSelectedText(state: state, text: text);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity updateSelectedFontSize({
    required MemeEditorStateEntity state,
    required double fontSize,
  }) {
    try {
      return _memeEditorDatasource.updateSelectedFontSize(
        state: state,
        fontSize: fontSize,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity moveTextLayerBy({
    required MemeEditorStateEntity state,
    required String layerId,
    required double deltaX,
    required double deltaY,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    try {
      return _memeEditorDatasource.moveTextLayerBy(
        state: state,
        layerId: layerId,
        deltaX: deltaX,
        deltaY: deltaY,
        canvasWidth: canvasWidth,
        canvasHeight: canvasHeight,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity removeSelectedTextLayer({
    required MemeEditorStateEntity state,
  }) {
    try {
      return _memeEditorDatasource.removeSelectedTextLayer(state: state);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity setFinalizedImageBytes({
    required MemeEditorStateEntity state,
    required Uint8List bytes,
  }) {
    try {
      return _memeEditorDatasource.setFinalizedImageBytes(
        state: state,
        bytes: bytes,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity toggleRecipientSelection({
    required MemeEditorStateEntity state,
    required String userId,
  }) {
    try {
      return _memeEditorDatasource.toggleRecipientSelection(
        state: state,
        userId: userId,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity clearRecipientSelection({
    required MemeEditorStateEntity state,
  }) {
    try {
      return _memeEditorDatasource.clearRecipientSelection(state: state);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  MemeEditorStateEntity optimizeCustomTemplateImageForUpload({
    required MemeEditorStateEntity state,
    required int maxImageBytes,
  }) {
    try {
      return _memeEditorDatasource.optimizeCustomTemplateImageForUpload(
        state: state,
        maxImageBytes: maxImageBytes,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
