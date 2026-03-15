import 'dart:async';
import 'dart:math' as math;
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
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/application/mutations/finalize_meme_image_mutation.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_controller_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/normalize_finalized_meme_bytes_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/resolve_meme_background_size_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/usecases/set_finalized_meme_bytes_usecase_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_image_size_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/normalize_finalized_meme_bytes_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/resolve_meme_background_size_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/set_finalized_meme_bytes_usecase.dart';
import 'package:memuno_app/src/features/create_meme/presentation/widgets/meme_editor_canvas.dart';
import 'package:memuno_app/src/features/create_meme/presentation/widgets/meme_editor_controls.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_item_entity.dart';
import 'package:memuno_app/src/features/meme_templates/presentation/widgets/meme_templates_bottom_sheet.dart';

/// Meme editor page where users compose one meme image.
class MemeEditorPage extends HookConsumerWidget {
  /// Creates the meme editor page.
  const MemeEditorPage({super.key});

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
    final bool isFinalizing = finalizeState.isPending;

    final TextEditingController selectedTextController =
        useTextEditingController();
    final FocusNode selectedTextFocusNode = useFocusNode();
    final ScrollController canvasScrollController = useScrollController();

    final ValueNotifier<bool> hasOpenedTemplatePicker = useState<bool>(false);
    final ValueNotifier<bool> shouldEditSelectedLayer = useState<bool>(false);
    final ObjectRef<bool> isSyncingSelectedText = useRef<bool>(false);
    final GlobalKey repaintBoundaryKey = useMemoized(GlobalKey.new);

    useListenable(selectedTextFocusNode);

    final bool isTextEditingActive = selectedTextFocusNode.hasFocus;
    final bool isSelectedLayerEditing =
        state.selectedTextLayerId != null &&
        (isTextEditingActive || shouldEditSelectedLayer.value);

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
      if (state.selectedTextLayerId == null && shouldEditSelectedLayer.value) {
        shouldEditSelectedLayer.value = false;
      }
      return null;
    }, <Object?>[state.selectedTextLayerId, shouldEditSelectedLayer.value]);

    useEffect(
      () {
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
              selectedTextFocusNode: selectedTextFocusNode,
              shouldEditSelectedLayer: shouldEditSelectedLayer,
              canvasScrollController: canvasScrollController,
            ),
          );
        });

        return null;
      },
      <Object?>[
        hasOpenedTemplatePicker.value,
        controller,
        selectedTextFocusNode,
        shouldEditSelectedLayer,
        canvasScrollController,
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

    void dismissTextEditing() {
      shouldEditSelectedLayer.value = false;
      selectedTextFocusNode.unfocus();
    }

    void keepTextEditingFocus({int retryFrames = 2}) {
      final String? selectedLayerId = state.selectedTextLayerId;
      if (selectedLayerId == null) {
        return;
      }

      shouldEditSelectedLayer.value = true;

      void requestFocusOnNextFrame(int remainingRetries) {
        WidgetsBinding.instance.addPostFrameCallback((Duration _) {
          if (!context.mounted) {
            return;
          }

          final MemeEditorStateEntity latestState = ref.read(
            memeEditorControllerProvider,
          );
          if (latestState.selectedTextLayerId != selectedLayerId) {
            return;
          }

          if (!selectedTextFocusNode.hasFocus) {
            selectedTextFocusNode.requestFocus();
          }

          if (!selectedTextFocusNode.hasFocus && remainingRetries > 0) {
            requestFocusOnNextFrame(remainingRetries - 1);
          }
        });
      }

      requestFocusOnNextFrame(retryFrames);
    }

    return MScaffold(
      resizeToAvoidBottomInset: false,
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.memeEditorTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => context.pop(),
            icon: LucideIcons.arrow_left,
            isEnabled: !isFinalizing,
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
                  selectedTextFocusNode: selectedTextFocusNode,
                  shouldEditSelectedLayer: shouldEditSelectedLayer,
                  canvasScrollController: canvasScrollController,
                ),
              );
            },
            icon: LucideIcons.images,
            isEnabled: !isFinalizing,
          ),
          MAppBarButton(
            onPressed: () {
              dismissTextEditing();
              unawaited(
                _submitFinalize(
                  ref: ref,
                  repaintBoundaryKey: repaintBoundaryKey,
                  unableToRenderMessage: l10n.memeEditorRenderError,
                  unableToConvertMessage: l10n.memeEditorPngEncodeError,
                ),
              );
            },
            icon: LucideIcons.check,
            isEnabled: state.canFinalize && !isFinalizing,
            isLoading: isFinalizing,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: MemeEditorCanvas(
              repaintBoundaryKey: repaintBoundaryKey,
              scrollController: canvasScrollController,
              template: state.template,
              layers: state.textLayers,
              selectedLayerId: state.selectedTextLayerId,
              selectedTextController: selectedTextController,
              selectedTextFocusNode: selectedTextFocusNode,
              isSelectedLayerEditing: isSelectedLayerEditing,
              isTextEditingActive: isTextEditingActive,
              onTapCanvas: (double positionX, double positionY) {
                try {
                  controller.addTextLayer(
                    initialText: '',
                    positionX: positionX,
                    positionY: positionY,
                  );
                  shouldEditSelectedLayer.value = true;
                } catch (error) {
                  feedback.resolveAndShowError(context, error);
                }
              },
              onTapOutsideWhileEditing: () {
                dismissTextEditing();
              },
              onTapLayer: (String layerId) {
                try {
                  controller.selectTextLayer(layerId);
                  shouldEditSelectedLayer.value = true;
                } catch (error) {
                  feedback.resolveAndShowError(context, error);
                }
              },
              onStartLayerTransform: (String _) {
                dismissTextEditing();
              },
              onDeleteLayer: (String layerId) {
                try {
                  controller.removeTextLayerById(layerId);
                } catch (error) {
                  feedback.resolveAndShowError(context, error);
                }
              },
              onTransformLayer:
                  (
                    String layerId,
                    double positionX,
                    double positionY,
                    double fontSize,
                    double rotationRadians,
                  ) {
                    try {
                      controller.updateTextLayerTransform(
                        layerId: layerId,
                        positionX: positionX,
                        positionY: positionY,
                        fontSize: fontSize,
                        rotationRadians: rotationRadians,
                      );
                    } catch (error) {
                      feedback.resolveAndShowError(context, error);
                    }
                  },
            ),
          ),
          if (isTextEditingActive && selectedLayer != null)
            AnimatedPadding(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: EdgeInsets.only(
                left: MSpacing.md,
                right: MSpacing.md,
                top: MSpacing.md,
                bottom:
                    math.max(
                      MediaQuery.viewInsetsOf(context).bottom,
                      MediaQuery.paddingOf(context).bottom,
                    ) +
                    MSpacing.md,
              ),
              child: TextFieldTapRegion(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) {
                    keepTextEditingFocus();
                  },
                  child: MemeEditorControls(
                    l10n: l10n,
                    layer: selectedLayer,
                    onTextColorChanged: (int colorValue) {
                      try {
                        keepTextEditingFocus();
                        controller.updateSelectedTextColor(colorValue);
                        keepTextEditingFocus();
                      } catch (error) {
                        feedback.resolveAndShowError(context, error);
                      }
                    },
                    onToggleTextBackground: () {
                      try {
                        keepTextEditingFocus();
                        controller.toggleSelectedTextBackground();
                        keepTextEditingFocus();
                      } catch (error) {
                        feedback.resolveAndShowError(context, error);
                      }
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Opens the picker and applies the selected template.
  Future<void> _pickTemplate({
    required BuildContext context,
    required MemeEditorController controller,
    required bool closePageOnCancel,
    required FocusNode selectedTextFocusNode,
    required ValueNotifier<bool> shouldEditSelectedLayer,
    required ScrollController canvasScrollController,
  }) async {
    final MemeTemplateListPageItemEntity? template =
        await showMemeTemplatesBottomSheet(context);

    if (!context.mounted) {
      return;
    }

    if (template == null) {
      if (closePageOnCancel) {
        context.pop();
      }
      return;
    }

    controller.setTemplate(template);
    _resetEditorInteractionState(
      selectedTextFocusNode: selectedTextFocusNode,
      shouldEditSelectedLayer: shouldEditSelectedLayer,
      canvasScrollController: canvasScrollController,
    );
  }

  /// Resets focus and viewport after selecting a new meme template.
  void _resetEditorInteractionState({
    required FocusNode selectedTextFocusNode,
    required ValueNotifier<bool> shouldEditSelectedLayer,
    required ScrollController canvasScrollController,
  }) {
    shouldEditSelectedLayer.value = false;
    selectedTextFocusNode.unfocus();

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!canvasScrollController.hasClients) {
        return;
      }
      canvasScrollController.jumpTo(0.0);
    });
  }

  /// Runs the finalize mutation and stores generated PNG bytes in state.
  Future<void> _submitFinalize({
    required WidgetRef ref,
    required GlobalKey repaintBoundaryKey,
    required String unableToRenderMessage,
    required String unableToConvertMessage,
  }) async {
    final Mutation<Uint8List> mutation = ref.read(
      finalizeMemeImageMutationProvider,
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final MemeEditorStateEntity currentState = ref.read(
        memeEditorControllerProvider,
      );
      final ResolveMemeBackgroundSizeUsecase resolveSizeUsecase = tx.get(
        resolveMemeBackgroundSizeUsecaseProvider,
      );
      final MemeImageSizeEntity targetSize = await resolveSizeUsecase(
        state: currentState,
      );

      final Uint8List capturedBytes = await _captureMemeBytes(
        repaintBoundaryKey: repaintBoundaryKey,
        targetSize: targetSize,
        unableToRenderMessage: unableToRenderMessage,
        unableToConvertMessage: unableToConvertMessage,
      );

      final NormalizeFinalizedMemeBytesUsecase normalizeUsecase = tx.get(
        normalizeFinalizedMemeBytesUsecaseProvider,
      );
      final Uint8List normalizedBytes = normalizeUsecase(
        bytes: capturedBytes,
        targetSize: targetSize,
      );

      final SetFinalizedMemeBytesUsecase setBytesUsecase = tx.get(
        setFinalizedMemeBytesUsecaseProvider,
      );
      final MemeEditorStateEntity nextState = setBytesUsecase(
        state: currentState,
        bytes: normalizedBytes,
      );

      ref
          .read(memeEditorControllerProvider.notifier)
          .setStateSnapshot(nextState);
      return normalizedBytes;
    });
  }

  /// Captures the editor [RepaintBoundary] and returns PNG bytes.
  Future<Uint8List> _captureMemeBytes({
    required GlobalKey repaintBoundaryKey,
    required MemeImageSizeEntity targetSize,
    required String unableToRenderMessage,
    required String unableToConvertMessage,
  }) async {
    await WidgetsBinding.instance.endOfFrame;

    final BuildContext? boundaryContext = repaintBoundaryKey.currentContext;
    final RenderObject? renderObject = boundaryContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw Failure.unknown(message: unableToRenderMessage);
    }

    final Size boundarySize = renderObject.size;
    if (boundarySize.width <= 0.0 || boundarySize.height <= 0.0) {
      throw Failure.unknown(message: unableToRenderMessage);
    }

    final double widthPixelRatio = targetSize.width / boundarySize.width;
    final double heightPixelRatio = targetSize.height / boundarySize.height;
    final double pixelRatio = math.max(
      1.0,
      math.min(widthPixelRatio, heightPixelRatio),
    );

    final ui.Image image = await renderObject.toImage(pixelRatio: pixelRatio);
    try {
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) {
        throw Failure.unknown(message: unableToConvertMessage);
      }

      return byteData.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }
}
