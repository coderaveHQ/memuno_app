import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/features/groups/application/mutations/group_invitation_reject_mutation.dart';
import 'package:memuno_app/src/features/groups/application/providers/group_invitations_list_provider.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_item_entity.dart';

/// Action button for rejecting one incoming group invitation.
class GroupInvitationRejectButton extends ConsumerWidget {
  const GroupInvitationRejectButton({super.key, required this.invitation});

  final GroupInvitationItemEntity invitation;

  Future<void> _submit(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      groupInvitationRejectMutationProvider(invitation.id),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref
          .read(groupInvitationsListProvider.notifier)
          .rejectInvitation(invitation);
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final Mutation<void> mutation = ref.watch(
      groupInvitationRejectMutationProvider(invitation.id),
    );
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isSubmitting = mutationState is MutationPending<void>;

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.groupsInvitationRejectSuccessMessage,
        );
      }
    });

    return MIconButton.destructive(
      onPressed: isSubmitting ? null : () => _submit(ref),
      isLoading: isSubmitting,
      icon: LucideIcons.x,
      dimension: 42.0,
    );
  }
}
