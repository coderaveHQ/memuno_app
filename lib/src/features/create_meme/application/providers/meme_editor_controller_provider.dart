import 'package:memuno_app/src/features/create_meme/application/providers/usecases/add_meme_text_layer_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/clear_meme_recipient_selection_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/remove_meme_text_layer_by_id_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/select_meme_text_layer_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/set_meme_template_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/toggle_selected_meme_text_background_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/toggle_meme_recipient_selection_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/update_meme_text_layer_transform_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/update_selected_meme_text_color_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/update_selected_meme_text_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_recipient_target_type.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/add_meme_text_layer_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/clear_meme_recipient_selection_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/remove_meme_text_layer_by_id_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/select_meme_text_layer_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/set_meme_template_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/toggle_meme_recipient_selection_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/toggle_selected_meme_text_background_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/update_meme_text_layer_transform_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/update_selected_meme_text_color_usecase.dart';
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

  /// Adds one text layer at normalized center position and selects it.
  void addTextLayer({
    required String initialText,
    required double positionX,
    required double positionY,
  }) {
    final AddMemeTextLayerUsecase usecase = ref.read(
      addMemeTextLayerUsecaseProvider,
    );
    state = usecase(
      state: state,
      initialText: initialText,
      positionX: positionX,
      positionY: positionY,
    );
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

  /// Updates transform fields of one text layer.
  void updateTextLayerTransform({
    required String layerId,
    required double positionX,
    required double positionY,
    required double fontSize,
    required double rotationRadians,
  }) {
    final UpdateMemeTextLayerTransformUsecase usecase = ref.read(
      updateMemeTextLayerTransformUsecaseProvider,
    );
    state = usecase(
      state: state,
      layerId: layerId,
      positionX: positionX,
      positionY: positionY,
      fontSize: fontSize,
      rotationRadians: rotationRadians,
    );
  }

  /// Updates text color of the selected layer.
  void updateSelectedTextColor(int colorValue) {
    final UpdateSelectedMemeTextColorUsecase usecase = ref.read(
      updateSelectedMemeTextColorUsecaseProvider,
    );
    state = usecase(state: state, colorValue: colorValue);
  }

  /// Toggles text outline visibility for the selected layer.
  void toggleSelectedTextBackground() {
    final ToggleSelectedMemeTextBackgroundUsecase usecase = ref.read(
      toggleSelectedMemeTextBackgroundUsecaseProvider,
    );
    state = usecase(state: state);
  }

  /// Removes one text layer identified by [layerId].
  void removeTextLayerById(String layerId) {
    final RemoveMemeTextLayerByIdUsecase usecase = ref.read(
      removeMemeTextLayerByIdUsecaseProvider,
    );
    state = usecase(state: state, layerId: layerId);
  }

  /// Replaces the full state snapshot.
  void setStateSnapshot(MemeEditorStateEntity nextState) {
    state = nextState;
  }

  /// Toggles selected recipient state for one polymorphic target.
  void toggleRecipientSelection({
    required MemeRecipientTargetType targetType,
    required String targetId,
  }) {
    final ToggleMemeRecipientSelectionUsecase usecase = ref.read(
      toggleMemeRecipientSelectionUsecaseProvider,
    );
    state = usecase(state: state, targetType: targetType, targetId: targetId);
  }

  /// Clears all selected recipients in the current send flow.
  void clearRecipientSelection() {
    final ClearMemeRecipientSelectionUsecase usecase = ref.read(
      clearMemeRecipientSelectionUsecaseProvider,
    );
    state = usecase(state: state);
  }
}
