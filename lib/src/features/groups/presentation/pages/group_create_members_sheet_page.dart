import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/features/groups/application/mutations/group_create_mutation.dart';
import 'package:memuno_app/src/features/groups/application/providers/group_create_draft_controller_provider.dart';
import 'package:memuno_app/src/features/groups/application/providers/groups_list_provider.dart';
import 'package:memuno_app/src/features/groups/application/providers/usecases/create_group_usecase_provider.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_create_draft_state_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/create_group_usecase.dart';
import 'package:memuno_app/src/features/groups/presentation/pages/groups_page.dart';
import 'package:memuno_app/src/features/groups/presentation/widgets/group_create_invitee_list.dart';

/// Step 2 page for selecting invitees and submitting group creation.
class GroupCreateMembersSheetPage extends HookConsumerWidget {
  const GroupCreateMembersSheetPage({super.key});

  void _onBack(BuildContext context) {
    Navigator.of(context).maybePop();
  }

  void _onClose(BuildContext context) {
    GroupsRoute(tab: GroupsPageTab.groups.routeValue).go(context);
  }

  Future<void> _submit(WidgetRef ref, GroupCreateDraftStateEntity draft) async {
    final Mutation<GroupItemEntity> mutation = ref.read(
      groupCreateMutationProvider,
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final CreateGroupUsecase usecase = tx.get(createGroupUsecaseProvider);
      final List<String> inviteeUserIds = draft.selectedInviteeUserIds.toList(
        growable: false,
      )..sort();

      final GroupItemEntity createdGroup = await usecase(
        name: draft.trimmedName,
        inviteeUserIds: inviteeUserIds,
      );

      ref.read(groupsListProvider.notifier).upsertGroup(createdGroup);
      return createdGroup;
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final TextEditingController searchController = useTextEditingController();
    final GroupCreateDraftStateEntity draft = ref.watch(
      groupCreateDraftControllerProvider,
    );

    useEffect(() {
      final notifier = ref.read(friendshipsListProvider.notifier);

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

    final Mutation<GroupItemEntity> mutation = ref.watch(
      groupCreateMutationProvider,
    );
    final MutationState<GroupItemEntity> mutationState = ref.watch(mutation);
    final bool isSubmitting = mutationState is MutationPending<GroupItemEntity>;

    ref.listen<MutationState<GroupItemEntity>>(mutation, (previous, next) {
      if (next is MutationError<GroupItemEntity>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<GroupItemEntity>) {
        feedback.showSuccess(context, message: l10n.groupsCreateSuccessMessage);
        ref.read(groupCreateDraftControllerProvider.notifier).reset();

        if (!context.mounted) {
          return;
        }

        GroupsRoute(tab: GroupsPageTab.groups.routeValue).go(context);
      }
    });

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          top: MSpacing.md,
          bottom: context.bottomPadding + MSpacing.md,
          left: context.leftPadding + MSpacing.md,
          right: context.rightPadding + MSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                MIconButton.secondary(
                  onPressed: isSubmitting ? null : () => _onBack(context),
                  icon: LucideIcons.arrow_left,
                  dimension: 42.0,
                ),
                const Spacer(),
                MIconButton.secondary(
                  onPressed: isSubmitting ? null : () => _onClose(context),
                  icon: LucideIcons.x,
                  dimension: 42.0,
                ),
              ],
            ),
            const MGap.sm(),
            MText.h3(
              text: l10n.groupsCreateMembersTitle,
              style: const TextStyle(color: MColors.gray100),
            ),
            const MGap.xs(),
            MText.small(
              text: l10n.groupsCreateMembersSubtitle(
                draft.selectedInviteeUserIds.length,
              ),
              style: const TextStyle(color: MColors.gray400),
            ),
            const MGap.md(),
            MTextField(
              controller: searchController,
              icon: LucideIcons.search,
              label: l10n.groupsCreateMembersSearchLabel,
              hint: l10n.groupsCreateMembersSearchHint,
              isEnabled: !isSubmitting,
            ),
            const MGap.md(),
            Expanded(
              child: GroupCreateInviteeList(
                selectedUserIds: draft.selectedInviteeUserIds,
                isEnabled: !isSubmitting,
                onToggle: (String userId) {
                  ref
                      .read(groupCreateDraftControllerProvider.notifier)
                      .toggleInvitee(userId);
                },
                listPadding: EdgeInsets.zero,
                childPadding: EdgeInsets.only(
                  top: MSpacing.md,
                  bottom: MSpacing.md,
                ),
                listChildPadding: EdgeInsets.only(
                  top: MSpacing.md,
                  bottom: MSpacing.md,
                ),
              ),
            ),
            const MGap.md(),
            MButton.primary(
              title: l10n.groupsCreateMembersSubmitButton,
              isLoading: isSubmitting,
              isEnabled: draft.canProceedFromNameStep && !isSubmitting,
              onPressed: draft.canProceedFromNameStep && !isSubmitting
                  ? () {
                      unawaited(_submit(ref, draft));
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
