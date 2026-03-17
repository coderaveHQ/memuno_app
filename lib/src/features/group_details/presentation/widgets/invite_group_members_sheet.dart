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
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/group_details/application/mutations/group_details_invite_members_mutation.dart';
import 'package:memuno_app/src/features/group_details/application/providers/usecases/invite_group_members_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/invite_group_members_usecase.dart';
import 'package:memuno_app/src/features/group_details/presentation/widgets/group_details_invitable_friends_list.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

/// Opens a full-height sheet that invites one or more users to a group.
Future<bool> showInviteGroupMembersSheet(
  BuildContext context, {
  required String groupId,
}) async {
  final bool? didInvite = await showModalSheet<bool>(
    context: context,
    useRootNavigator: true,
    swipeDismissible: true,
    viewportPadding: EdgeInsets.only(
      top: MediaQuery.viewPaddingOf(context).top,
    ),
    builder: (BuildContext _) {
      return InviteGroupMembersSheet(groupId: groupId);
    },
  );

  return didInvite ?? false;
}

/// Full-height sheet widget for selecting and inviting group members.
class InviteGroupMembersSheet extends HookConsumerWidget {
  const InviteGroupMembersSheet({super.key, required this.groupId});

  final String groupId;

  Future<void> _submit(WidgetRef ref, Set<String> selectedUserIds) async {
    final Mutation<void> mutation = ref.read(
      groupDetailsInviteMembersMutationProvider(groupId),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final InviteGroupMembersUsecase usecase = tx.get(
        inviteGroupMembersUsecaseProvider,
      );

      final List<String> inviteeUserIds = selectedUserIds.toList(
        growable: false,
      )..sort();

      await usecase(groupId: groupId, inviteeUserIds: inviteeUserIds);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ValueNotifier<Set<String>> selectedUserIds = useState<Set<String>>(
      <String>{},
    );

    final Mutation<void> mutation = ref.watch(
      groupDetailsInviteMembersMutationProvider(groupId),
    );
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isSubmitting = mutationState.isPending;

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.groupDetailsInviteMembersSuccessMessage,
        );
        context.pop(true);
      }
    });

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
                            text: l10n.groupDetailsInviteMembersDialogTitle,
                            style: const TextStyle(color: MColors.gray100),
                          ),
                          const MGap.xs(),
                          MText.small(
                            text: l10n.groupDetailsInviteMembersSelected(
                              selectedUserIds.value.length,
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
                child: GroupDetailsInvitableFriendsList(
                  groupId: groupId,
                  selectedUserIds: selectedUserIds.value,
                  isEnabled: !isSubmitting,
                  onToggle: (String userId) {
                    final Set<String> next = Set<String>.from(
                      selectedUserIds.value,
                    );
                    if (next.contains(userId)) {
                      next.remove(userId);
                    } else {
                      next.add(userId);
                    }
                    selectedUserIds.value = Set<String>.unmodifiable(next);
                  },
                  listPadding: EdgeInsets.zero,
                  listChildPadding: EdgeInsets.zero,
                  childPadding: EdgeInsets.only(
                    left: context.leftPadding + MSpacing.md,
                    right: context.rightPadding + MSpacing.md,
                  ),
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
                    unawaited(_submit(ref, selectedUserIds.value));
                  },
                  isEnabled: selectedUserIds.value.isNotEmpty && !isSubmitting,
                  isLoading: isSubmitting,
                  title: l10n.groupDetailsInviteMembersSubmitButton,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
