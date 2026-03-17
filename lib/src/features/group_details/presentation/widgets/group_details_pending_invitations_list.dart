import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/features/group_details/application/mutations/group_details_cancel_invitation_mutation.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_pending_invitations_list_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_pending_invitation_item_entity.dart';

/// List view for pending invitations in group-details info.
class GroupDetailsPendingInvitationsListView extends StatelessWidget {
  const GroupDetailsPendingInvitationsListView({
    super.key,
    required this.groupId,
    required this.canManageInvitations,
    this.onRefresh,
    this.onInvitationMutated,
  });

  final String groupId;
  final bool canManageInvitations;
  final Future<void> Function(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  )?
  onRefresh;
  final VoidCallback? onInvitationMutated;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MAsyncList<GroupPendingInvitationItemEntity, ListCursorEntity>(
      provider: groupDetailsPendingInvitationsListProvider(groupId),
      emptyText: l10n.groupDetailsPendingInvitationsEmpty,
      loadMoreExtent: 220.0,
      onRefresh: onRefresh,
      listPadding: EdgeInsets.only(
        top: 20.0,
        bottom: context.bottomPadding + MSpacing.md,
      ),
      childPadding: EdgeInsets.only(
        top: 20.0,
        bottom: context.bottomPadding + MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
      ),
      itemBuilder:
          (BuildContext context, GroupPendingInvitationItemEntity invitation) {
            return GroupDetailsPendingInvitationListItem(
              groupId: groupId,
              invitation: invitation,
              canCancel: canManageInvitations,
              onInvitationMutated: onInvitationMutated,
            );
          },
    );
  }
}

/// Canonical list item widget for one pending invitation row.
class GroupDetailsPendingInvitationListItem extends ConsumerWidget {
  const GroupDetailsPendingInvitationListItem({
    super.key,
    required this.groupId,
    required this.invitation,
    required this.canCancel,
    this.onInvitationMutated,
  });

  final String groupId;
  final GroupPendingInvitationItemEntity invitation;
  final bool canCancel;
  final VoidCallback? onInvitationMutated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final Mutation<void> mutation = ref.watch(
      groupDetailsCancelInvitationMutationProvider(invitation.id),
    );
    final MutationState<void> mutationState = ref.watch(mutation);
    final bool isCanceling = mutationState is MutationPending<void>;

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.groupDetailsInvitationCancelSuccessMessage,
        );
      }
    });

    return MListTile(
      leading: MAvatar(name: invitation.invitee.name, dimension: 48.0),
      title: invitation.invitee.name,
      description: l10n.groupsInvitationFrom(
        invitation.inviter.name,
        invitation.inviter.friendshipCode,
      ),
      details:
          '${l10n.userDetailsFriendshipCodeLabel} ${invitation.invitee.friendshipCode} • '
          '${invitation.createdAt.formatDateOnly(fullDate: true)}',
      trailing: canCancel
          ? MIconButton.destructive(
              onPressed: isCanceling ? null : () => _cancelInvitation(ref),
              isLoading: isCanceling,
              icon: LucideIcons.x,
              dimension: 42.0,
            )
          : null,
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }

  Future<void> _cancelInvitation(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      groupDetailsCancelInvitationMutationProvider(invitation.id),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref
          .read(groupDetailsPendingInvitationsListProvider(groupId).notifier)
          .cancelInvitation(invitation);
      onInvitationMutated?.call();
    });
  }
}
