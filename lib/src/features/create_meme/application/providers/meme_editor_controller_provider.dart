import 'dart:typed_data';

import 'package:memuno_app/src/features/create_meme/application/providers/usecases/add_meme_text_layer_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/clear_meme_recipient_selection_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/move_meme_text_layer_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/optimize_custom_template_image_for_upload_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/remove_selected_meme_text_layer_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/select_meme_text_layer_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/set_custom_meme_template_image_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/set_finalized_meme_bytes_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/set_meme_template_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/toggle_meme_recipient_selection_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/update_selected_meme_text_font_size_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/update_selected_meme_text_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/add_meme_text_layer_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/clear_meme_recipient_selection_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/move_meme_text_layer_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/optimize_custom_template_image_for_upload_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/remove_selected_meme_text_layer_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/select_meme_text_layer_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/set_custom_meme_template_image_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/set_finalized_meme_bytes_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/set_meme_template_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/toggle_meme_recipient_selection_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/update_selected_meme_text_font_size_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/update_selected_meme_text_usecase.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_editor_controller_provider.g.dart';

/// Local state controller for one meme editor session.
@riverpod
class MemeEditorController extends _$MemeEditorController {
  @override
  /// Builds the initial meme editor state.
  MemeEditorStateEntity build() {
    return MemeEditorStateEntity.initial();
  }

  /// Applies a selected [template] and resets draft state.
  void setTemplate(MemeTemplateListPageItemEntity template) {
    final SetMemeTemplateUsecase usecase = ref.read(
      setMemeTemplateUsecaseProvider,
    );
    state = usecase(state: state, template: template);
  }

  /// Applies one custom gallery image as meme background and resets draft state.
  void setCustomTemplateImage({
    required Uint8List imageBytes,
    required double aspectRatio,
  }) {
    final SetCustomMemeTemplateImageUsecase usecase = ref.read(
      setCustomMemeTemplateImageUsecaseProvider,
    );
    state = usecase(
      state: state,
      imageBytes: imageBytes,
      aspectRatio: aspectRatio,
    );
  }

  /// Adds one text layer and selects it.
  void addTextLayer({String initialText = 'Text'}) {
    final AddMemeTextLayerUsecase usecase = ref.read(
      addMemeTextLayerUsecaseProvider,
    );
    state = usecase(state: state, initialText: initialText);
  }

  /// Selects one text layer by [layerId] or clears selection when null.
  void selectTextLayer(String? layerId) {
    final SelectMemeTextLayerUsecase usecase = ref.read(
      selectMemeTextLayerUsecaseProvider,
    );
    state = usecase(state: state, layerId: layerId);
  }

  /// Updates text of the selected layer.
  void updateSelectedText(String text) {
    final UpdateSelectedMemeTextUsecase usecase = ref.read(
      updateSelectedMemeTextUsecaseProvider,
    );
    state = usecase(state: state, text: text);
  }

  /// Updates font size of the selected layer.
  void updateSelectedFontSize(double fontSize) {
    final UpdateSelectedMemeTextFontSizeUsecase usecase = ref.read(
      updateSelectedMemeTextFontSizeUsecaseProvider,
    );
    state = usecase(state: state, fontSize: fontSize);
  }

  /// Moves one layer by drag delta in editor coordinates.
  void moveTextLayerBy({
    required String layerId,
    required double deltaX,
    required double deltaY,
    required double canvasWidth,
    required double canvasHeight,
  }) {
    final MoveMemeTextLayerUsecase usecase = ref.read(
      moveMemeTextLayerUsecaseProvider,
    );
    state = usecase(
      state: state,
      layerId: layerId,
      deltaX: deltaX,
      deltaY: deltaY,
      canvasWidth: canvasWidth,
      canvasHeight: canvasHeight,
    );
  }

  /// Removes the currently selected text layer.
  void removeSelectedTextLayer() {
    final RemoveSelectedMemeTextLayerUsecase usecase = ref.read(
      removeSelectedMemeTextLayerUsecaseProvider,
    );
    state = usecase(state: state);
  }

  /// Replaces the full state snapshot.
  void setStateSnapshot(MemeEditorStateEntity nextState) {
    state = nextState;
  }

  /// Stores finalized image [bytes] in local state without mutation flow.
  void setFinalizedImageBytes(Uint8List bytes) {
    final SetFinalizedMemeBytesUsecase usecase = ref.read(
      setFinalizedMemeBytesUsecaseProvider,
    );
    state = usecase(state: state, bytes: bytes);
  }

  /// Toggles selected recipient state for one friendship [userId].
  void toggleRecipientSelection(String userId) {
    final ToggleMemeRecipientSelectionUsecase usecase = ref.read(
      toggleMemeRecipientSelectionUsecaseProvider,
    );
    state = usecase(state: state, userId: userId);
  }

  /// Clears all selected recipients in the current send flow.
  void clearRecipientSelection() {
    final ClearMemeRecipientSelectionUsecase usecase = ref.read(
      clearMemeRecipientSelectionUsecaseProvider,
    );
    state = usecase(state: state);
  }

  /// Optimizes selected custom image bytes for upload-size budget.
  void optimizeCustomTemplateImageForUpload() {
    final OptimizeCustomTemplateImageForUploadUsecase usecase = ref.read(
      optimizeCustomTemplateImageForUploadUsecaseProvider,
    );
    state = usecase(state: state);
  }
}
