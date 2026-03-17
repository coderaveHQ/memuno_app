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
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/features/group_details/application/mutations/group_details_remove_member_mutation.dart';
import 'package:memuno_app/src/features/group_details/application/mutations/group_details_update_member_role_mutation.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_members_list_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_member_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

/// List view for members in group-details info.
class GroupDetailsMembersListView extends StatelessWidget {
  const GroupDetailsMembersListView({
    super.key,
    required this.groupId,
    required this.currentUserId,
    required this.canManageMembers,
    this.onRefresh,
    this.onMemberMutated,
  });

  final String groupId;
  final String? currentUserId;
  final bool canManageMembers;
  final Future<void> Function(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  )?
  onRefresh;
  final VoidCallback? onMemberMutated;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MAsyncList<GroupMemberItemEntity, ListCursorEntity>(
      provider: groupDetailsMembersListProvider(groupId),
      emptyText: l10n.groupDetailsMembersEmpty,
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
      itemBuilder: (BuildContext context, GroupMemberItemEntity member) {
        return GroupDetailsMemberListItem(
          groupId: groupId,
          member: member,
          currentUserId: currentUserId,
          canManageMembers: canManageMembers,
          onMemberMutated: onMemberMutated,
        );
      },
    );
  }
}

/// Canonical list item widget for one group member row.
class GroupDetailsMemberListItem extends ConsumerWidget {
  const GroupDetailsMemberListItem({
    super.key,
    required this.groupId,
    required this.member,
    required this.currentUserId,
    required this.canManageMembers,
    this.onMemberMutated,
  });

  final String groupId;
  final GroupMemberItemEntity member;
  final String? currentUserId;
  final bool canManageMembers;
  final VoidCallback? onMemberMutated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final String memberKey = '$groupId:${member.user.id}';

    final Mutation<void> removeMutation = ref.watch(
      groupDetailsRemoveMemberMutationProvider(memberKey),
    );
    final MutationState<void> removeState = ref.watch(removeMutation);
    final bool isRemoving = removeState is MutationPending<void>;

    final Mutation<void> updateRoleMutation = ref.watch(
      groupDetailsUpdateMemberRoleMutationProvider(memberKey),
    );
    final MutationState<void> updateRoleState = ref.watch(updateRoleMutation);
    final bool isUpdatingRole = updateRoleState is MutationPending<void>;
    final bool isMutating = isRemoving || isUpdatingRole;

    final bool isCurrentUser =
        currentUserId != null && member.user.id == currentUserId;
    final bool canToggleRole =
        canManageMembers && member.type != GroupUserType.creator;
    final bool canRemove =
        canManageMembers &&
        !isCurrentUser &&
        member.type != GroupUserType.creator;
    final bool canShowActions = canToggleRole || canRemove;

    final GroupUserType? nextRole = switch (member.type) {
      GroupUserType.member => GroupUserType.admin,
      GroupUserType.admin => GroupUserType.member,
      GroupUserType.creator => null,
    };

    ref.listen<MutationState<void>>(removeMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.groupDetailsMemberRemoveSuccessMessage,
        );
      }
    });

    ref.listen<MutationState<void>>(updateRoleMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.groupDetailsMemberRoleUpdateSuccessMessage,
        );
      }
    });

    return MListTile(
      onPressed: () {
        UserDetailsRoute(userId: member.user.id).push<void>(context);
      },
      leading: MAvatar(name: member.user.name, dimension: 48.0),
      title: member.user.name,
      description:
          '${l10n.userDetailsFriendshipCodeLabel} ${member.user.friendshipCode}',
      details:
          '${_roleLabel(l10n, member.type)} • ${member.createdAt.formatDateOnly(fullDate: true)}',
      trailing: canShowActions
          ? MIconButton.secondary(
              onPressed: isMutating
                  ? null
                  : () => _onOpenActions(
                      context,
                      ref,
                      l10n,
                      canToggleRole: canToggleRole,
                      canRemove: canRemove,
                      nextRole: nextRole,
                    ),
              isLoading: isMutating,
              icon: LucideIcons.ellipsis_vertical,
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

  Future<void> _onOpenActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    required bool canToggleRole,
    required bool canRemove,
    required GroupUserType? nextRole,
  }) async {
    final _MemberAction? action = await _showMemberActionsSheet(
      context,
      l10n,
      canToggleRole: canToggleRole,
      canRemove: canRemove,
      memberType: member.type,
    );

    if (action == null) {
      return;
    }

    if (action == _MemberAction.removeMember) {
      await _removeMember(ref);
      return;
    }

    if (action == _MemberAction.toggleRole && nextRole != null) {
      await _updateMemberRole(ref, nextRole: nextRole);
    }
  }

  Future<void> _removeMember(WidgetRef ref) async {
    final String memberKey = '$groupId:${member.user.id}';
    final Mutation<void> mutation = ref.read(
      groupDetailsRemoveMemberMutationProvider(memberKey),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref
          .read(groupDetailsMembersListProvider(groupId).notifier)
          .removeMember(member);
      onMemberMutated?.call();
    });
  }

  Future<void> _updateMemberRole(
    WidgetRef ref, {
    required GroupUserType nextRole,
  }) async {
    final String memberKey = '$groupId:${member.user.id}';
    final Mutation<void> mutation = ref.read(
      groupDetailsUpdateMemberRoleMutationProvider(memberKey),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref
          .read(groupDetailsMembersListProvider(groupId).notifier)
          .updateMemberRole(member: member, nextType: nextRole);
      onMemberMutated?.call();
    });
  }

  Future<_MemberAction?> _showMemberActionsSheet(
    BuildContext context,
    AppLocalizations l10n, {
    required bool canToggleRole,
    required bool canRemove,
    required GroupUserType memberType,
  }) {
    final String roleActionTitle = memberType == GroupUserType.admin
        ? l10n.groupDetailsMemberActionDemoteToMember
        : l10n.groupDetailsMemberActionPromoteToAdmin;

    return showModalSheet<_MemberAction>(
      context: context,
      useRootNavigator: true,
      swipeDismissible: true,
      builder: (BuildContext context) {
        return Sheet(
          initialOffset: const SheetOffset(1),
          snapGrid: const SheetSnapGrid.single(snap: SheetOffset(1)),
          decoration: const MaterialSheetDecoration(
            size: SheetSize.fit,
            color: MColors.gray900,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
            clipBehavior: Clip.antiAlias,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                top: MSpacing.md,
                bottom: context.bottomPadding + MSpacing.md,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MText.h4(
                    text: l10n.groupDetailsMemberActionsTitle,
                    style: const TextStyle(color: MColors.gray100),
                  ),
                  const MGap.md(),
                  if (canToggleRole)
                    MButton.secondary(
                      onPressed: () {
                        Navigator.of(context).pop(_MemberAction.toggleRole);
                      },
                      title: roleActionTitle,
                    ),
                  if (canToggleRole && canRemove) const MGap.sm(),
                  if (canRemove)
                    MButton.destructive(
                      onPressed: () {
                        Navigator.of(context).pop(_MemberAction.removeMember);
                      },
                      title: l10n.groupDetailsMemberActionRemove,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _roleLabel(AppLocalizations l10n, GroupUserType type) {
    return switch (type) {
      GroupUserType.creator => l10n.groupDetailsMemberRoleCreator,
      GroupUserType.admin => l10n.groupDetailsMemberRoleAdmin,
      GroupUserType.member => l10n.groupDetailsMemberRoleMember,
    };
  }
}

enum _MemberAction { toggleRole, removeMember }
