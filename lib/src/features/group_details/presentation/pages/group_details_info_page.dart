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
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_tab_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/group_details/application/mutations/group_details_delete_mutation.dart';
import 'package:memuno_app/src/features/group_details/application/mutations/group_details_leave_mutation.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_members_list_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_pending_invitations_list_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/usecases/delete_group_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_details_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/delete_group_usecase.dart';
import 'package:memuno_app/src/features/group_details/presentation/widgets/group_details_members_list.dart';
import 'package:memuno_app/src/features/group_details/presentation/widgets/group_details_pending_invitations_list.dart';
import 'package:memuno_app/src/features/group_details/presentation/widgets/invite_group_members_sheet.dart';
import 'package:memuno_app/src/features/group_details/presentation/widgets/update_group_details_name_dialog.dart';
import 'package:memuno_app/src/features/groups/application/providers/groups_list_provider.dart';
import 'package:memuno_app/src/features/groups/application/providers/usecases/leave_group_usecase_provider.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/leave_group_usecase.dart';
import 'package:memuno_app/src/features/groups/presentation/pages/groups_page.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class GroupDetailsInfoPage extends HookConsumerWidget {
  final String groupId;

  const GroupDetailsInfoPage({super.key, required this.groupId});

  void _onBack(BuildContext context) {
    context.pop();
  }

  Future<void> _refreshLists(WidgetRef ref) {
    return Future.wait<void>(<Future<void>>[
      ref.read(groupDetailsMembersListProvider(groupId).notifier).refresh(),
      ref
          .read(groupDetailsPendingInvitationsListProvider(groupId).notifier)
          .refresh(),
    ]);
  }

  Future<void> _onRefresh(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      final AsyncValue<GroupDetailsEntity> _ = ref.refresh(
        groupDetailsProvider(groupId),
      );
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }

    try {
      await _refreshLists(ref);
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }
  }

  Future<void> _leaveGroup(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      groupDetailsLeaveMutationProvider(groupId),
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final LeaveGroupUsecase usecase = tx.get(leaveGroupUsecaseProvider);
      await usecase(groupId: groupId);
    });
  }

  Future<void> _deleteGroup(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      groupDetailsDeleteMutationProvider(groupId),
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final DeleteGroupUsecase usecase = tx.get(deleteGroupUsecaseProvider);
      await usecase(groupId: groupId);
    });
  }

  Future<void> _onInviteMembers(
    BuildContext context,
    WidgetRef ref,
    AppFeedback feedback,
  ) async {
    final bool didInvite = await showInviteGroupMembersSheet(
      context,
      groupId: groupId,
    );
    if (!didInvite) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await _onRefresh(ref, context, feedback);
    ref.invalidate(groupDetailsProvider(groupId));
  }

  Future<void> _onUpdateName(
    BuildContext context,
    WidgetRef ref, {
    required String initialName,
    required AppFeedback feedback,
  }) async {
    final bool didUpdate = await showUpdateGroupDetailsNameDialog(
      context,
      groupId: groupId,
      initialName: initialName,
    );
    if (!didUpdate) {
      return;
    }

    ref.invalidate(groupDetailsProvider(groupId));
    try {
      await ref.read(groupsListProvider.notifier).refresh();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      feedback.resolveAndShowError(context, error);
    }
  }

  Future<void> _onOpenGroupActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AppFeedback feedback, {
    required GroupDetailsEntity? details,
    required bool canAddMembers,
    required bool canUpdateName,
    required bool canShowLeave,
    required bool canShowDelete,
  }) async {
    final _GroupAction? action = await _showGroupActionsSheet(
      context,
      l10n,
      canAddMembers: canAddMembers,
      canUpdateName: canUpdateName,
      canShowLeave: canShowLeave,
      canShowDelete: canShowDelete,
    );
    if (action == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    if (action == _GroupAction.inviteMembers) {
      await _onInviteMembers(context, ref, feedback);
      return;
    }

    if (action == _GroupAction.updateName) {
      if (details == null) {
        return;
      }

      await _onUpdateName(
        context,
        ref,
        initialName: details.name,
        feedback: feedback,
      );
      return;
    }

    if (action == _GroupAction.leaveGroup) {
      await _leaveGroup(ref);
      return;
    }

    if (action == _GroupAction.deleteGroup) {
      await _deleteGroup(ref);
    }
  }

  Future<_GroupAction?> _showGroupActionsSheet(
    BuildContext context,
    AppLocalizations l10n, {
    required bool canAddMembers,
    required bool canUpdateName,
    required bool canShowLeave,
    required bool canShowDelete,
  }) {
    final List<Widget> actions = <Widget>[];

    void addAction(Widget action) {
      if (actions.isNotEmpty) {
        actions.add(const MGap.sm());
      }
      actions.add(action);
    }

    if (canAddMembers) {
      addAction(
        MButton.secondary(
          onPressed: () {
            Navigator.of(context).pop(_GroupAction.inviteMembers);
          },
          title: l10n.groupDetailsInviteMembersDialogTitle,
        ),
      );
    }

    if (canUpdateName) {
      addAction(
        MButton.secondary(
          onPressed: () {
            Navigator.of(context).pop(_GroupAction.updateName);
          },
          title: l10n.groupDetailsUpdateNameDialogTitle,
        ),
      );
    }

    if (canShowLeave) {
      addAction(
        MButton.destructive(
          onPressed: () {
            Navigator.of(context).pop(_GroupAction.leaveGroup);
          },
          title: l10n.groupDetailsGroupActionLeave,
        ),
      );
    }

    if (canShowDelete) {
      addAction(
        MButton.destructive(
          onPressed: () {
            Navigator.of(context).pop(_GroupAction.deleteGroup);
          },
          title: l10n.groupDetailsGroupActionDelete,
        ),
      );
    }

    return showModalSheet<_GroupAction>(
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
                    text: l10n.groupDetailsGroupActionsTitle,
                    style: const TextStyle(color: MColors.gray100),
                  ),
                  const MGap.md(),
                  ...actions,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final TabController tabController = useTabController(initialLength: 2);
    final String? currentUserId = ref.watch(currentUserProvider)?.id;
    final AsyncValue<GroupDetailsEntity> groupDetailsState = ref.watch(
      groupDetailsProvider(groupId),
    );

    final GroupDetailsEntity? details = groupDetailsState.value;
    final bool canShowLeave =
        details?.isMember == true && (details?.memberCount ?? 0) > 1;
    final bool canShowDelete = details?.canDeleteGroup == true;
    final bool canManageMembers = details?.canManageMembers == true;
    final bool canAddMembers = details?.canAddMembers == true;
    final bool canUpdateName = canManageMembers && details != null;
    final bool canShowGroupActions =
        canAddMembers || canUpdateName || canShowLeave || canShowDelete;

    final Mutation<void> leaveMutation = ref.watch(
      groupDetailsLeaveMutationProvider(groupId),
    );
    final MutationState<void> leaveState = ref.watch(leaveMutation);
    final bool isLeaving = leaveState is MutationPending<void>;

    final Mutation<void> deleteMutation = ref.watch(
      groupDetailsDeleteMutationProvider(groupId),
    );
    final MutationState<void> deleteState = ref.watch(deleteMutation);
    final bool isDeleting = deleteState is MutationPending<void>;
    final bool isActionPending = isLeaving || isDeleting;

    ref.listen<MutationState<void>>(leaveMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.groupDetailsLeaveSuccessMessage,
        );
        ref.invalidate(groupDetailsProvider(groupId));
        ref.read(groupsListProvider.notifier).refresh();
        if (!context.mounted) return;
        GroupsRoute(tab: GroupsPageTab.groups.routeValue).go(context);
      }
    });

    ref.listen<MutationState<void>>(deleteMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.groupDetailsDeleteSuccessMessage,
        );
        ref.invalidate(groupDetailsProvider(groupId));
        ref.read(groupsListProvider.notifier).refresh();
        if (!context.mounted) return;
        GroupsRoute(tab: GroupsPageTab.groups.routeValue).go(context);
      }
    });

    final MAppBar appBar = MAppBar(
      context: context,
      title: MAppBarTitle(
        text: groupDetailsState.when<String>(
          data: (GroupDetailsEntity value) => value.name,
          error: (Object _, StackTrace _) => '???',
          loading: () => l10n.groupsTitle,
        ),
      ),
      leading: <MAppBarButton>[
        MAppBarButton(
          onPressed: () => _onBack(context),
          icon: LucideIcons.arrow_left,
          isEnabled: !isActionPending,
        ),
      ],
      trailing: <MAppBarButton>[
        if (canShowGroupActions)
          MAppBarButton(
            onPressed: isActionPending
                ? null
                : () => _onOpenGroupActions(
                    context,
                    ref,
                    l10n,
                    feedback,
                    details: details,
                    canAddMembers: canAddMembers,
                    canUpdateName: canUpdateName,
                    canShowLeave: canShowLeave,
                    canShowDelete: canShowDelete,
                  ),
            isLoading: isActionPending,
            icon: LucideIcons.ellipsis_vertical,
            isEnabled: !isActionPending,
          ),
      ],
      bottom: MTabBar(
        controller: tabController,
        titles: <String>[
          l10n.groupDetailsInfoTabMembers,
          l10n.groupDetailsInfoTabInvitations,
        ],
      ),
    );

    return MScaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Padding(
        padding: EdgeInsets.only(top: appBar.preferredSize.height - 20.0),
        child: TabBarView(
          controller: tabController,
          children: <Widget>[
            GroupDetailsMembersListView(
              groupId: groupId,
              currentUserId: currentUserId,
              canManageMembers: canManageMembers,
              onMemberMutated: () =>
                  ref.invalidate(groupDetailsProvider(groupId)),
              onRefresh:
                  (WidgetRef ref, BuildContext context, AppFeedback feedback) =>
                      _onRefresh(ref, context, feedback),
            ),
            GroupDetailsPendingInvitationsListView(
              groupId: groupId,
              canManageInvitations: canManageMembers,
              onInvitationMutated: () =>
                  ref.invalidate(groupDetailsProvider(groupId)),
              onRefresh:
                  (WidgetRef ref, BuildContext context, AppFeedback feedback) =>
                      _onRefresh(ref, context, feedback),
            ),
          ],
        ),
      ),
    );
  }
}

enum _GroupAction { inviteMembers, updateName, leaveGroup, deleteGroup }
