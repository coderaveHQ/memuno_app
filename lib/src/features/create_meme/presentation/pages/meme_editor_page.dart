import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/create_meme/application/mutations/finalize_meme_image_mutation.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_controller_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/optimize_custom_template_image_for_upload_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/set_finalized_meme_bytes_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/optimize_custom_template_image_for_upload_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/set_finalized_meme_bytes_usecase.dart';
import 'package:memuno_app/src/features/create_meme/presentation/widgets/meme_editor_canvas.dart';
import 'package:memuno_app/src/features/create_meme/presentation/widgets/meme_editor_controls.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_picker_selection_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/picked_meme_template_image_entity.dart';
import 'package:memuno_app/src/features/meme_templates/presentation/widgets/meme_templates_bottom_sheet.dart';

/// Meme editor page where users compose one meme image.
class MemeEditorPage extends HookConsumerWidget {
  /// Creates the meme editor page.
  const MemeEditorPage({super.key});

  static const double _maxRenderPixelRatio = 3.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MemeEditorStateEntity state = ref.watch(memeEditorControllerProvider);
    final MemeEditorController controller = ref.read(
      memeEditorControllerProvider.notifier,
    );
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);

    final Mutation<Uint8List> finalizeMutation = ref.watch(
      finalizeMemeImageMutationProvider,
    );
    final MutationState<Uint8List> finalizeState = ref.watch(finalizeMutation);
    final bool isFinalizing = finalizeState is MutationPending<Uint8List>;

    final TextEditingController selectedTextController =
        useTextEditingController();
    final FocusNode selectedTextFocusNode = useFocusNode();
    final ValueNotifier<bool> hasOpenedTemplatePicker = useState<bool>(false);
    final ValueNotifier<bool> hideSelectionOverlay = useState<bool>(false);
    final ObjectRef<bool> isSyncingSelectedText = useRef<bool>(false);
    final ObjectRef<bool> hasHeldTextFieldFocus = useRef<bool>(false);
    final GlobalKey repaintBoundaryKey = useMemoized(GlobalKey.new);

    final MemeTextLayerEntity? selectedLayer = state.selectedTextLayer;

    ref.listen<MutationState<Uint8List>>(finalizeMutation, (previous, next) {
      if (next is MutationError<Uint8List>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<Uint8List>) {
        unawaited(
          SendRoute(next.value.toList(growable: false)).push<void>(context),
        );
      }
    });

    useEffect(() {
      if (hasOpenedTemplatePicker.value) {
        return null;
      }

      hasOpenedTemplatePicker.value = true;
      WidgetsBinding.instance.addPostFrameCallback((Duration _) {
        unawaited(
          _pickTemplate(
            context: context,
            controller: controller,
            closePageOnCancel: true,
          ),
        );
      });

      return null;
    }, <Object?>[hasOpenedTemplatePicker.value, controller]);

    useEffect(
      () {
        void listener() {
          final bool hasFocus = selectedTextFocusNode.hasFocus;
          if (hasFocus) {
            hasHeldTextFieldFocus.value = true;
            return;
          }

          if (!hasHeldTextFieldFocus.value) {
            return;
          }

          hasHeldTextFieldFocus.value = false;
          if (state.selectedTextLayerId == null) {
            return;
          }

          try {
            controller.selectTextLayer(null);
          } catch (error) {
            WidgetsBinding.instance.addPostFrameCallback((Duration _) {
              if (!context.mounted) {
                return;
              }
              feedback.resolveAndShowError(context, error);
            });
          }
        }

        selectedTextFocusNode.addListener(listener);
        return () {
          selectedTextFocusNode.removeListener(listener);
        };
      },
      <Object?>[
        selectedTextFocusNode,
        hasHeldTextFieldFocus,
        state.selectedTextLayerId,
        controller,
        feedback,
      ],
    );

    useEffect(
      () {
        final String text = selectedLayer?.text ?? '';
        if (selectedTextController.text == text) {
          return null;
        }

        isSyncingSelectedText.value = true;
        selectedTextController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
        isSyncingSelectedText.value = false;
        return null;
      },
      <Object?>[
        selectedLayer?.id,
        selectedLayer?.text,
        selectedTextController,
        isSyncingSelectedText,
      ],
    );

    useEffect(
      () {
        void listener() {
          if (isSyncingSelectedText.value) {
            return;
          }

          if (state.selectedTextLayerId == null) {
            return;
          }

          try {
            controller.updateSelectedText(selectedTextController.text);
          } catch (error) {
            WidgetsBinding.instance.addPostFrameCallback((Duration _) {
              if (!context.mounted) {
                return;
              }
              feedback.resolveAndShowError(context, error);
            });
          }
        }

        selectedTextController.addListener(listener);
        return () {
          selectedTextController.removeListener(listener);
        };
      },
      <Object?>[
        selectedTextController,
        state.selectedTextLayerId,
        controller,
        feedback,
        isSyncingSelectedText,
      ],
    );

    final EdgeInsets controlsHorizontalPadding = EdgeInsets.only(
      left: context.leftPadding + MSpacing.md,
      right: context.rightPadding + MSpacing.md,
    );

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.memeEditorTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => context.pop(),
            icon: LucideIcons.arrow_left,
          ),
        ],
        trailing: <MAppBarButton>[
          MAppBarButton(
            onPressed: () {
              unawaited(
                _pickTemplate(
                  context: context,
                  controller: controller,
                  closePageOnCancel: false,
                ),
              );
            },
            icon: LucideIcons.images,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(
          top: MSpacing.md,
          bottom: context.bottomPadding + MSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: MemeEditorCanvas(
                repaintBoundaryKey: repaintBoundaryKey,
                template: state.template,
                customTemplateImageBytes: state.customTemplateImageBytes,
                customTemplateAspectRatio: state.customTemplateAspectRatio,
                layers: state.textLayers,
                selectedLayerId: state.selectedTextLayerId,
                showSelectionOverlay: !hideSelectionOverlay.value,
                onSelectLayer: (String? layerId) {
                  try {
                    controller.selectTextLayer(layerId);
                    if (layerId != null) {
                      WidgetsBinding.instance.addPostFrameCallback((
                        Duration _,
                      ) {
                        if (!context.mounted) {
                          return;
                        }
                        selectedTextFocusNode.requestFocus();
                      });
                    }
                  } catch (error) {
                    feedback.resolveAndShowError(context, error);
                  }
                },
                onMoveLayer:
                    (
                      String layerId,
                      double deltaX,
                      double deltaY,
                      Size imageBoundsSize,
                    ) {
                      try {
                        controller.moveTextLayerBy(
                          layerId: layerId,
                          deltaX: deltaX,
                          deltaY: deltaY,
                          canvasWidth: imageBoundsSize.width,
                          canvasHeight: imageBoundsSize.height,
                        );
                      } catch (error) {
                        feedback.resolveAndShowError(context, error);
                      }
                    },
              ),
            ),
            const MGap.md(),
            Padding(
              padding: controlsHorizontalPadding,
              child: MemeEditorControls(
                selectedLayer: selectedLayer,
                selectedTextController: selectedTextController,
                selectedTextFocusNode: selectedTextFocusNode,
                l10n: l10n,
                onAddText: () {
                  try {
                    controller.addTextLayer(
                      initialText: l10n.memeEditorDefaultText,
                    );
                    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
                      if (!context.mounted) {
                        return;
                      }
                      selectedTextFocusNode.requestFocus();
                    });
                  } catch (error) {
                    feedback.resolveAndShowError(context, error);
                  }
                },
                onDeleteSelectedText: () {
                  try {
                    controller.removeSelectedTextLayer();
                  } catch (error) {
                    feedback.resolveAndShowError(context, error);
                  }
                },
                onFontSizeChanged: (double fontSize) {
                  try {
                    controller.updateSelectedFontSize(fontSize);
                  } catch (error) {
                    feedback.resolveAndShowError(context, error);
                  }
                },
              ),
            ),
            const MGap.md(),
            Padding(
              padding: controlsHorizontalPadding,
              child: MButton.primary(
                title: l10n.memeEditorFinalizeButton,
                onPressed: () {
                  unawaited(
                    _submitFinalize(
                      ref: ref,
                      repaintBoundaryKey: repaintBoundaryKey,
                      hideSelectionOverlay: hideSelectionOverlay,
                      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
                      unableToRenderMessage: l10n.memeEditorRenderError,
                      unableToConvertMessage: l10n.memeEditorPngEncodeError,
                    ),
                  );
                },
                isLoading: isFinalizing,
                isEnabled: state.canFinalize && !isFinalizing,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the picker and applies selected template or gallery image.
  Future<void> _pickTemplate({
    required BuildContext context,
    required MemeEditorController controller,
    required bool closePageOnCancel,
  }) async {
    final MemeTemplatePickerSelectionEntity? selection =
        await showMemeTemplatesBottomSheet(context);

    if (!context.mounted) {
      return;
    }

    if (selection == null) {
      if (closePageOnCancel) {
        context.pop();
      }
      return;
    }

    final MemeTemplateListPageItemEntity? template = selection.template;
    if (template != null) {
      controller.setTemplate(template);
      return;
    }

    final PickedMemeTemplateImageEntity? pickedImage = selection.pickedImage;
    if (pickedImage != null) {
      controller.setCustomTemplateImage(
        imageBytes: pickedImage.pngBytes,
        aspectRatio: pickedImage.aspectRatio,
      );
    }
  }

  /// Runs the finalize mutation and stores generated PNG bytes in state.
  Future<void> _submitFinalize({
    required WidgetRef ref,
    required GlobalKey repaintBoundaryKey,
    required ValueNotifier<bool> hideSelectionOverlay,
    required double devicePixelRatio,
    required String unableToRenderMessage,
    required String unableToConvertMessage,
  }) async {
    final Mutation<Uint8List> mutation = ref.read(
      finalizeMemeImageMutationProvider,
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      hideSelectionOverlay.value = true;
      try {
        final MemeEditorStateEntity stateBeforeOptimization = ref.read(
          memeEditorControllerProvider,
        );
        if (stateBeforeOptimization.hasCustomTemplateImage) {
          final OptimizeCustomTemplateImageForUploadUsecase optimizeUsecase = tx
              .get(optimizeCustomTemplateImageForUploadUsecaseProvider);
          final MemeEditorStateEntity optimizedState = optimizeUsecase(
            state: stateBeforeOptimization,
          );
          ref
              .read(memeEditorControllerProvider.notifier)
              .setStateSnapshot(optimizedState);
          await WidgetsBinding.instance.endOfFrame;
        }

        final Uint8List bytes = await _captureMemeBytes(
          repaintBoundaryKey: repaintBoundaryKey,
          devicePixelRatio: devicePixelRatio,
          unableToRenderMessage: unableToRenderMessage,
          unableToConvertMessage: unableToConvertMessage,
        );

        final SetFinalizedMemeBytesUsecase usecase = tx.get(
          setFinalizedMemeBytesUsecaseProvider,
        );
        final MemeEditorStateEntity currentState = ref.read(
          memeEditorControllerProvider,
        );
        final MemeEditorStateEntity nextState = usecase(
          state: currentState,
          bytes: bytes,
        );

        ref
            .read(memeEditorControllerProvider.notifier)
            .setStateSnapshot(nextState);
        return bytes;
      } finally {
        hideSelectionOverlay.value = false;
      }
    });
  }

  /// Captures the editor [RepaintBoundary] and returns PNG bytes.
  Future<Uint8List> _captureMemeBytes({
    required GlobalKey repaintBoundaryKey,
    required double devicePixelRatio,
    required String unableToRenderMessage,
    required String unableToConvertMessage,
  }) async {
    await WidgetsBinding.instance.endOfFrame;

    final BuildContext? boundaryContext = repaintBoundaryKey.currentContext;
    final RenderObject? renderObject = boundaryContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError(unableToRenderMessage);
    }

    final double clampedPixelRatio = devicePixelRatio.clamp(
      1.0,
      _maxRenderPixelRatio,
    );

    final ui.Image image = await renderObject.toImage(
      pixelRatio: clampedPixelRatio,
    );
    try {
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw StateError(unableToConvertMessage);
      }

      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}
