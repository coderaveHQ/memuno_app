import 'dart:async';

import 'package:flutter/material.dart';
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
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_radio_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/application/mutations/meme_recipients_add_mutation.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/meme_addable_recipient_targets_list_provider.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/usecases/add_meme_recipients_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/add_meme_recipients_usecase.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

/// Opens a full-height sheet that adds one or more meme recipients.
Future<bool> showAddMemeRecipientsSheet(
  BuildContext context, {
  required String memeId,
}) async {
  final bool? didAdd = await showModalSheet<bool>(
    context: context,
    useRootNavigator: true,
    swipeDismissible: true,
    viewportPadding: EdgeInsets.only(
      top: MediaQuery.viewPaddingOf(context).top,
    ),
    builder: (BuildContext _) {
      return AddMemeRecipientsSheet(memeId: memeId);
    },
  );

  return didAdd ?? false;
}

/// Full-height sheet widget for selecting and adding meme recipients.
class AddMemeRecipientsSheet extends HookConsumerWidget {
  const AddMemeRecipientsSheet({super.key, required this.memeId});

  final String memeId;

  Future<void> _submit(
    WidgetRef ref,
    Set<String> selectedUserIds,
    Set<String> selectedGroupIds,
  ) async {
    final Mutation<void> mutation = ref.read(
      memeRecipientsAddMutationProvider(memeId),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final AddMemeRecipientsUsecase usecase = tx.get(
        addMemeRecipientsUsecaseProvider,
      );

      final List<String> recipientUserIds = selectedUserIds.toList(
        growable: false,
      )..sort();
      final List<String> recipientGroupIds = selectedGroupIds.toList(
        growable: false,
      )..sort();

      await usecase(
        memeId: memeId,
        recipientUserIds: recipientUserIds,
        recipientGroupIds: recipientGroupIds,
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    final ValueNotifier<Set<String>> selectedUserIds = useState<Set<String>>(
      <String>{},
    );
    final ValueNotifier<Set<String>> selectedGroupIds = useState<Set<String>>(
      <String>{},
    );

    final Mutation<void> mutation = ref.watch(
      memeRecipientsAddMutationProvider(memeId),
    );
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isSubmitting = mutationState.isPending;

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.memeDetailsRecipientsAddSuccessMessage,
        );
        context.pop(true);
      }
    });

    final int selectedCount =
        selectedUserIds.value.length + selectedGroupIds.value.length;

    return SheetPopScope<bool>(
      canPop: !isSubmitting,
      child: Sheet(
        initialOffset: const SheetOffset(1),
        snapGrid: const SheetSnapGrid.single(snap: SheetOffset(1)),
        decoration: const MaterialSheetDecoration(
          size: SheetSize.stretch,
          color: MColors.gray900,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          clipBehavior: Clip.antiAlias,
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: MSpacing.md,
                  bottom: MSpacing.md,
                  left: context.leftPadding + MSpacing.md,
                  right: context.rightPadding + MSpacing.md,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MText.h3(
                            text: l10n.memeDetailsAddRecipientsTitle,
                            style: const TextStyle(color: MColors.gray100),
                          ),
                          const MGap.xs(),
                          MText.small(
                            text: l10n.memeDetailsAddRecipientsSelected(
                              selectedCount,
                            ),
                            style: const TextStyle(color: MColors.gray400),
                          ),
                        ],
                      ),
                    ),
                    const MGap.md(),
                    MIconButton.secondary(
                      onPressed: () => context.pop(),
                      icon: LucideIcons.x,
                      dimension: kToolbarHeight - 4.0,
                      isEnabled: !isSubmitting,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MAsyncList<MemeRecipientTargetItemEntity, ListCursorEntity>(
                  provider: memeAddableRecipientTargetsListProvider(memeId),
                  emptyText: l10n.memeDetailsAddRecipientsEmpty,
                  loadMoreExtent: 220.0,
                  listPadding: EdgeInsets.zero,
                  childPadding: EdgeInsets.zero,
                  listChildPadding: EdgeInsets.zero,
                  itemBuilder:
                      (
                        BuildContext context,
                        MemeRecipientTargetItemEntity target,
                      ) {
                        final bool isSelected = target.isUser
                            ? selectedUserIds.value.contains(target.id)
                            : selectedGroupIds.value.contains(target.id);

                        final Widget leading = target.isUser
                            ? MAvatar(name: target.name, dimension: 48.0)
                            : MIconButton.secondary(
                                icon: LucideIcons.users,
                                dimension: 48.0,
                                background: MColors.gray200,
                                foreground: MColors.gray900,
                              );

                        final String description = target.isUser
                            ? '${l10n.userDetailsFriendshipCodeLabel} ${target.friendshipCode ?? ''}'
                            : l10n.groupsMemberCount(target.memberCount ?? 0);

                        return MListTile(
                          onPressed: !isSubmitting
                              ? () {
                                  if (target.isUser) {
                                    final Set<String> next = Set<String>.from(
                                      selectedUserIds.value,
                                    );
                                    if (next.contains(target.id)) {
                                      next.remove(target.id);
                                    } else {
                                      next.add(target.id);
                                    }
                                    selectedUserIds.value =
                                        Set<String>.unmodifiable(next);
                                  } else {
                                    final Set<String> next = Set<String>.from(
                                      selectedGroupIds.value,
                                    );
                                    if (next.contains(target.id)) {
                                      next.remove(target.id);
                                    } else {
                                      next.add(target.id);
                                    }
                                    selectedGroupIds.value =
                                        Set<String>.unmodifiable(next);
                                  }
                                }
                              : null,
                          isEnabled: !isSubmitting,
                          leading: leading,
                          title: target.name,
                          description: description,
                          trailing: MRadioIndicator(isSelected: isSelected),
                          padding: EdgeInsets.only(
                            top: MSpacing.md,
                            left: context.leftPadding + MSpacing.md,
                            right: context.rightPadding + MSpacing.md,
                            bottom: MSpacing.md,
                          ),
                        );
                      },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: MSpacing.md,
                  bottom: MSpacing.md,
                  left: context.leftPadding + MSpacing.md,
                  right: context.rightPadding + MSpacing.md,
                ),
                child: MButton.primary(
                  onPressed: () {
                    unawaited(
                      _submit(
                        ref,
                        selectedUserIds.value,
                        selectedGroupIds.value,
                      ),
                    );
                  },
                  isEnabled: selectedCount > 0 && !isSubmitting,
                  isLoading: isSubmitting,
                  title: l10n.memeDetailsAddRecipientsSubmitButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
