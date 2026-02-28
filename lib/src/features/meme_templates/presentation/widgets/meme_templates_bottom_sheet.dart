import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_progress_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_modal_bottom_sheet.dart';
import 'package:memuno_app/src/app/widgets/m/m_refresh_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_reload.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_tappable.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/features/meme_templates/application/providers/meme_templates_list_provider.dart';
import 'package:memuno_app/src/features/meme_templates/application/providers/usecases/pick_and_crop_meme_template_image_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_picker_selection_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/picked_meme_template_image_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/usecases/pick_and_crop_meme_template_image_usecase.dart';

/// Opens the meme-template picker and returns the selected payload.
Future<MemeTemplatePickerSelectionEntity?> showMemeTemplatesBottomSheet(
  BuildContext context,
) async {
  return showMModalBottomSheet<MemeTemplatePickerSelectionEntity>(
    context,
    isScrollControlled: true,
    builder: (BuildContext _) {
      return const MemeTemplatesBottomSheet();
    },
  );
}

/// Bottom-sheet widget showing paginated and searchable meme templates.
class MemeTemplatesBottomSheet extends HookConsumerWidget {
  /// Creates the meme-template picker bottom sheet.
  const MemeTemplatesBottomSheet({super.key});

  /// Refreshes current template query from page 1.
  Future<void> _onRefresh(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      await ref.read(memeTemplatesListProvider.notifier).refresh();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      feedback.resolveAndShowError(context, error);
    }
  }

  /// Loads the next template page if available.
  Future<void> _onLoadMore(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      await ref.read(memeTemplatesListProvider.notifier).loadMore();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      feedback.resolveAndShowError(context, error);
    }
  }

  /// Picks one gallery image, crops it, and returns picker selection payload.
  Future<void> _onPickFromGallery(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    final PickAndCropMemeTemplateImageUsecase usecase = ref.read(
      pickAndCropMemeTemplateImageUsecaseProvider,
    );

    final PickedMemeTemplateImageEntity? pickedImage;
    try {
      pickedImage = await usecase();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      feedback.resolveAndShowError(context, error);
      return;
    }

    if (!context.mounted || pickedImage == null) {
      return;
    }

    try {
      context.pop(
        MemeTemplatePickerSelectionEntity.gallery(pickedImage: pickedImage),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      feedback.resolveAndShowError(context, error);
    }
  }

  /// Returns the total number of grid cells for current [state].
  int _itemCount(
    PaginatedListState<MemeTemplateEntity, MemeTemplateCursorEntity> state,
  ) {
    if (state.items.isEmpty) {
      return 0;
    }

    final bool showTailLoader = state.isLoadingMore || state.hasMore;
    return state.items.length + (showTailLoader ? 1 : 0);
  }

  @override
  /// Builds the meme-template picker UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final TextEditingController searchController = useTextEditingController();

    useEffect(() {
      final MemeTemplatesList notifier = ref.read(
        memeTemplatesListProvider.notifier,
      );

      // Always reset to an unfiltered query when opening the sheet.
      unawaited(notifier.clearSearch());

      void listener() {
        notifier.applySearchDebounced(searchController.text);
      }

      searchController.addListener(listener);
      return () {
        notifier.cancelPendingSearch();
        searchController.removeListener(listener);
      };
    }, <Object?>[searchController]);

    final AsyncValue<
      PaginatedListState<MemeTemplateEntity, MemeTemplateCursorEntity>
    >
    asyncTemplates = ref.watch(memeTemplatesListProvider);

    final EdgeInsets paddingWithoutBottom = EdgeInsets.only(
      top: MSpacing.md,
      bottom: MSpacing.md,
      left: context.leftPadding + MSpacing.md,
      right: context.rightPadding + MSpacing.md,
    );
    final EdgeInsets paddingWithBottom = paddingWithoutBottom.copyWith(
      bottom: context.bottomPadding + MSpacing.md,
    );
    const double galleryButtonBottomOffset = 56.0;

    return MModalBottomSheet(
      title: l10n.memeTemplatePickerTitle,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: paddingWithoutBottom.copyWith(top: 0.0),
                child: MTextField(
                  controller: searchController,
                  icon: LucideIcons.search,
                  label: l10n.memeTemplatePickerSearchLabel,
                  hint: l10n.memeTemplatePickerSearchHint,
                ),
              ),
              Expanded(
                child: asyncTemplates.when(
                  data:
                      (
                        PaginatedListState<
                          MemeTemplateEntity,
                          MemeTemplateCursorEntity
                        >
                        templatesState,
                      ) {
                        final List<MemeTemplateEntity> templates =
                            templatesState.items;
                        return NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification notification) {
                            if (notification.metrics.extentAfter < 500.0) {
                              unawaited(_onLoadMore(ref, context, feedback));
                            }
                            return false;
                          },
                          child: MRefreshIndicator(
                            onRefresh: () => _onRefresh(ref, context, feedback),
                            child: MasonryGridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.only(
                                bottom:
                                    context.bottomPadding +
                                    galleryButtonBottomOffset +
                                    MSpacing.xl,
                              ),
                              gridDelegate:
                                  SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                  ),
                              crossAxisSpacing: MSpacing.xs,
                              mainAxisSpacing: MSpacing.xs,
                              itemCount: _itemCount(templatesState),
                              itemBuilder: (BuildContext context, int index) {
                                if (templates.isEmpty) {
                                  return MReload(
                                    onReload: () =>
                                        _onRefresh(ref, context, feedback),
                                    padding: paddingWithoutBottom,
                                    text: l10n.memeTemplatePickerEmpty,
                                  );
                                }

                                if (index >= templates.length) {
                                  if (!templatesState.isLoadingMore) {
                                    return const SizedBox.shrink();
                                  }

                                  return MCenter(
                                    padding: paddingWithoutBottom,
                                    child: const MCircularProgressIndicator(),
                                  );
                                }

                                final MemeTemplateEntity template =
                                    templates[index];
                                return _MemeTemplateGridItem(
                                  template: template,
                                  isEnabled: true,
                                );
                              },
                            ),
                          ),
                        );
                      },
                  error: (Object e, StackTrace _) {
                    final String message = feedback.resolve(context, e);
                    return MReload(
                      onReload: () => _onRefresh(ref, context, feedback),
                      padding: paddingWithBottom,
                      text: message,
                    );
                  },
                  loading: () {
                    return MCenter(
                      padding: paddingWithBottom,
                      child: const MCircularProgressIndicator(),
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
                bottom: context.bottomPadding + MSpacing.md,
              ),
              child: MButton.primary(
                title: l10n.memeTemplatePickerGalleryButton,
                isExpanded: false,
                onPressed: () {
                  unawaited(_onPickFromGallery(ref, context, feedback));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selectable masonry tile showing one meme-template preview image.
final class _MemeTemplateGridItem extends StatelessWidget {
  /// Creates a template preview tile.
  const _MemeTemplateGridItem({
    required this.template,
    required this.isEnabled,
  });

  /// Domain model returned to the caller when selected.
  final MemeTemplateEntity template;

  /// Whether the tile is currently interactive.
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final double safeAspectRatio = template.aspectRatio <= 0
        ? 1.0
        : template.aspectRatio.clamp(0.35, 2.5).toDouble();

    return MTappable(
      onPressed: () {
        context.pop(
          MemeTemplatePickerSelectionEntity.template(template: template),
        );
      },
      isEnabled: isEnabled,
      child: Container(
        color: MColors.gray800,
        child: AspectRatio(
          aspectRatio: safeAspectRatio,
          child: Image.network(
            template.signedImageUrl,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            loadingBuilder:
                (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? loadingProgress,
                ) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(child: MCircularProgressIndicator());
                },
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stackTrace) {
                  return const Center(
                    child: Icon(
                      LucideIcons.image_off,
                      color: MColors.gray400,
                      size: 20.0,
                    ),
                  );
                },
          ),
        ),
      ),
    );
  }
}
