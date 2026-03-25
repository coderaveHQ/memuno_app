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
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/router/route_utils.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_tab_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/friendships/application/mutations/create_friendship_request_mutation.dart';
import 'package:memuno_app/src/features/friendships/application/mutations/delete_friendship_mutation.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_requests_list_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/create_friendship_request_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/delete_friendship_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/create_friendship_request_usecase.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/delete_friendship_usecase.dart';
import 'package:memuno_app/src/features/moderation/domain/entities/ugc_report_reason.dart';
import 'package:memuno_app/src/features/moderation/domain/entities/ugc_report_target_type.dart';
import 'package:memuno_app/src/features/moderation/presentation/widgets/moderation_report_reason_sheet.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_other_all_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_other_received_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_other_sent_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_block_status_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_report_can_create_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_own_all_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_own_received_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_own_sent_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_provider.dart';
import 'package:memuno_app/src/features/user_details/application/mutations/user_moderation_mutations.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/update_current_user_details_name_dialog.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_other_all_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_other_received_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_other_sent_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_own_all_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_own_received_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_own_sent_memes_list.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

/// User-details page for viewing account-level user data.
class UserDetailsPage extends HookConsumerWidget {
  /// Creates the user-details page.
  const UserDetailsPage({super.key, required this.userId});

  /// User id whose details are rendered.
  final String userId;

  void _onBack(BuildContext context) {
    context.pop();
  }

  Future<void> _refreshOwnLists(WidgetRef ref) {
    return Future.wait<void>(<Future<void>>[
      ref.read(userDetailsOwnAllMemesListProvider.notifier).refresh(),
      ref.read(userDetailsOwnSentMemesListProvider.notifier).refresh(),
      ref.read(userDetailsOwnReceivedMemesListProvider.notifier).refresh(),
    ]);
  }

  Future<void> _refreshOtherLists(WidgetRef ref) {
    return Future.wait<void>(<Future<void>>[
      ref.read(userDetailsOtherAllMemesListProvider(userId).notifier).refresh(),
      ref
          .read(userDetailsOtherSentMemesListProvider(userId).notifier)
          .refresh(),
      ref
          .read(userDetailsOtherReceivedMemesListProvider(userId).notifier)
          .refresh(),
    ]);
  }

  Future<void> _onRefresh(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback, {
    required bool isOwnUser,
  }) async {
    try {
      final AsyncValue<UserDetailsEntity> _ = ref.refresh(
        userDetailsProvider(userId),
      );
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }

    try {
      if (isOwnUser) {
        await _refreshOwnLists(ref);
      } else {
        await _refreshOtherLists(ref);
      }
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }
  }

  /// Opens the update-name dialog for the current user.
  Future<void> _onUpdateName(
    BuildContext context, {
    required String initialName,
  }) async {
    await showUpdateCurrentUserDetailsNameDialog(
      context,
      userId: userId,
      initialName: initialName,
    );
  }

  Future<void> _removeFriendship(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      deleteFriendshipMutationProvider(userId),
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final DeleteFriendshipUsecase usecase = tx.get(
        deleteFriendshipUsecaseProvider,
      );
      await usecase(friendId: userId);
      ref.invalidate(friendshipsListProvider);
    });
  }

  Future<void> _createFriendshipRequest(
    WidgetRef ref, {
    required String addresseeFriendshipCode,
  }) async {
    final Mutation<FriendshipRequestListPageItemEntity> mutation = ref.read(
      createFriendshipRequestMutationProvider,
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final CreateFriendshipRequestUsecase usecase = tx.get(
        createFriendshipRequestUsecaseProvider,
      );
      final FriendshipRequestListPageItemEntity created = await usecase(
        addresseeFriendshipCode: addresseeFriendshipCode,
      );
      ref.read(friendshipRequestsListProvider.notifier).prependRequest(created);
      ref.invalidate(userDetailsProvider(userId));
      return created;
    });
  }

  Future<void> _reportUser(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final SupabaseClient supabaseClient = ref.read(supabaseClientProvider);
    final UgcReportReason? reason;
    try {
      reason = await showModerationReportReasonPicker(
        context,
        supabaseClient: supabaseClient,
        title: l10n.moderationReportDialogTitleUser,
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      feedback.resolveAndShowError(context, error);
      return;
    }
    if (!context.mounted) {
      return;
    }
    if (reason == null) {
      return;
    }
    final UgcReportReason selectedReason = reason;

    final Mutation<void> mutation = ref.read(
      reportUserMutationProvider(userId),
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final SupabaseClient txSupabaseClient = tx.get(supabaseClientProvider);
      await txSupabaseClient.rpc<void>(
        'ugc_report_create',
        params: <String, dynamic>{
          'p_target_type': UgcReportTargetType.user.databaseValue,
          'p_target_id': userId,
          'p_reason': selectedReason.databaseValue,
        },
      );
    });
  }

  Future<void> _blockUser(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(blockUserMutationProvider(userId));
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final SupabaseClient supabaseClient = tx.get(supabaseClientProvider);
      await supabaseClient.rpc<void>(
        'user_block',
        params: <String, dynamic>{'p_target_user_id': userId},
      );
      ref.invalidate(userBlockStatusProvider(userId));
      ref.invalidate(userDetailsProvider(userId));
      ref.invalidate(friendshipsListProvider);
      ref.invalidate(friendshipRequestsListProvider);
    });
  }

  Future<void> _unblockUser(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      unblockUserMutationProvider(userId),
    );
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final SupabaseClient supabaseClient = tx.get(supabaseClientProvider);
      await supabaseClient.rpc<void>(
        'user_unblock',
        params: <String, dynamic>{'p_target_user_id': userId},
      );
      ref.invalidate(userBlockStatusProvider(userId));
      ref.invalidate(userDetailsProvider(userId));
      ref.invalidate(friendshipsListProvider);
      ref.invalidate(friendshipRequestsListProvider);
    });
  }

  Future<void> _onOpenUserActions(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    required bool canUpdateName,
    required bool canRemoveFriend,
    required bool canCreateFriendRequest,
    required bool canReportUser,
    required bool canBlockUser,
    required bool canUnblockUser,
    required UserDetailsEntity? userDetails,
  }) async {
    final _UserDetailsAction? action = await _showUserDetailsActionsSheet(
      context,
      l10n,
      canUpdateName: canUpdateName,
      canRemoveFriend: canRemoveFriend,
      canCreateFriendRequest: canCreateFriendRequest,
      canReportUser: canReportUser,
      canBlockUser: canBlockUser,
      canUnblockUser: canUnblockUser,
    );
    if (action == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    if (action == _UserDetailsAction.updateName) {
      if (userDetails == null) {
        return;
      }
      await _onUpdateName(context, initialName: userDetails.name);
      return;
    }

    if (action == _UserDetailsAction.removeFriend) {
      await _removeFriendship(ref);
      return;
    }

    if (action == _UserDetailsAction.createFriendRequest) {
      if (userDetails == null) {
        return;
      }
      await _createFriendshipRequest(
        ref,
        addresseeFriendshipCode: userDetails.friendshipCode,
      );
      return;
    }

    if (action == _UserDetailsAction.reportUser) {
      await _reportUser(context, ref, l10n);
      return;
    }

    if (action == _UserDetailsAction.blockUser) {
      await _blockUser(ref);
      return;
    }

    if (action == _UserDetailsAction.unblockUser) {
      await _unblockUser(ref);
    }
  }

  Future<_UserDetailsAction?> _showUserDetailsActionsSheet(
    BuildContext context,
    AppLocalizations l10n, {
    required bool canUpdateName,
    required bool canRemoveFriend,
    required bool canCreateFriendRequest,
    required bool canReportUser,
    required bool canBlockUser,
    required bool canUnblockUser,
  }) {
    final List<Widget> actions = <Widget>[];

    void addAction(Widget action) {
      if (actions.isNotEmpty) {
        actions.add(const MGap.sm());
      }
      actions.add(action);
    }

    if (canUpdateName) {
      addAction(
        MButton.secondary(
          onPressed: () {
            Navigator.of(context).pop(_UserDetailsAction.updateName);
          },
          title: l10n.userDetailsUpdateNameDialogTitle,
        ),
      );
    }

    if (canRemoveFriend) {
      addAction(
        MButton.destructive(
          onPressed: () {
            Navigator.of(context).pop(_UserDetailsAction.removeFriend);
          },
          title: l10n.userDetailsActionRemoveFriend,
        ),
      );
    }

    if (canCreateFriendRequest) {
      addAction(
        MButton.secondary(
          onPressed: () {
            Navigator.of(context).pop(_UserDetailsAction.createFriendRequest);
          },
          title: l10n.friendshipsAddDialogTitle,
        ),
      );
    }

    if (canReportUser) {
      addAction(
        MButton.secondary(
          onPressed: () {
            Navigator.of(context).pop(_UserDetailsAction.reportUser);
          },
          title: l10n.moderationActionReportUser,
        ),
      );
    }

    if (canBlockUser) {
      addAction(
        MButton.destructive(
          onPressed: () {
            Navigator.of(context).pop(_UserDetailsAction.blockUser);
          },
          title: l10n.moderationActionBlockUser,
        ),
      );
    }

    if (canUnblockUser) {
      addAction(
        MButton.secondary(
          onPressed: () {
            Navigator.of(context).pop(_UserDetailsAction.unblockUser);
          },
          title: l10n.moderationActionUnblockUser,
        ),
      );
    }

    return showModalSheet<_UserDetailsAction>(
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
                    text: l10n.userDetailsActionsTitle,
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

  bool _isUserReportConflictError(Object error) {
    return error is PostgrestException && error.code == '23505';
  }

  @override
  /// Builds the page UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final TabController tabController = useTabController(initialLength: 3);
    final bool isProfileRoute = RouteUtils.isLeaf(
      context,
      CurrentUserDetailsRoute.routeName,
    );
    final bool isCurrentUser = ref.watch(currentUserProvider)?.id == userId;
    final bool canModerateOtherUser = !isProfileRoute && !isCurrentUser;
    final AsyncValue<bool> blockedState = canModerateOtherUser
        ? ref.watch(userBlockStatusProvider(userId))
        : const AsyncValue<bool>.data(false);
    final AsyncValue<bool> reportCanCreateState = canModerateOtherUser
        ? ref.watch(userReportCanCreateProvider(userId))
        : const AsyncValue<bool>.data(false);
    final bool isBlocked = blockedState.value ?? false;

    final AsyncValue<UserDetailsEntity> userDetailsState = ref.watch(
      userDetailsProvider(userId),
    );
    final UserDetailsEntity? userDetails = userDetailsState.value;
    final bool canUpdateName = isProfileRoute && userDetails != null;
    final bool canRemoveFriend =
        !isProfileRoute &&
        !isCurrentUser &&
        userDetails != null &&
        userDetails.isFriend &&
        !isBlocked;
    final bool canCreateFriendRequest =
        !isProfileRoute &&
        !isCurrentUser &&
        userDetails != null &&
        !userDetails.isFriend &&
        !userDetails.hasPendingFriendshipRequest &&
        !isBlocked;
    final bool canReportUser =
        canModerateOtherUser && (reportCanCreateState.value ?? false);
    final bool canBlockUser = canModerateOtherUser && !isBlocked;
    final bool canUnblockUser = canModerateOtherUser && isBlocked;
    final bool hasAvailableActions =
        canUpdateName ||
        canRemoveFriend ||
        canCreateFriendRequest ||
        canReportUser ||
        canBlockUser ||
        canUnblockUser;

    final Mutation<void> deleteFriendshipMutation = ref.watch(
      deleteFriendshipMutationProvider(userId),
    );
    final MutationState<void> deleteFriendshipState = ref.watch(
      deleteFriendshipMutation,
    );
    final bool isRemovingFriend =
        deleteFriendshipState is MutationPending<void>;
    final Mutation<FriendshipRequestListPageItemEntity>
    createFriendshipRequestMutation = ref.watch(
      createFriendshipRequestMutationProvider,
    );
    final MutationState<FriendshipRequestListPageItemEntity>
    createFriendshipRequestState = ref.watch(createFriendshipRequestMutation);
    final bool isCreatingFriendRequest =
        createFriendshipRequestState
            is MutationPending<FriendshipRequestListPageItemEntity>;
    final Mutation<void> reportUserMutation = ref.watch(
      reportUserMutationProvider(userId),
    );
    final MutationState<void> reportUserState = ref.watch(reportUserMutation);
    final bool isReportingUser = reportUserState is MutationPending<void>;
    final Mutation<void> blockUserMutation = ref.watch(
      blockUserMutationProvider(userId),
    );
    final MutationState<void> blockUserState = ref.watch(blockUserMutation);
    final bool isBlockingUser = blockUserState is MutationPending<void>;
    final Mutation<void> unblockUserMutation = ref.watch(
      unblockUserMutationProvider(userId),
    );
    final MutationState<void> unblockUserState = ref.watch(unblockUserMutation);
    final bool isUnblockingUser = unblockUserState is MutationPending<void>;
    final bool isAnyActionPending =
        isRemovingFriend ||
        isCreatingFriendRequest ||
        isReportingUser ||
        isBlockingUser ||
        isUnblockingUser;
    final bool isActionButtonEnabled =
        hasAvailableActions && !isAnyActionPending;

    ref.listen<MutationState<void>>(deleteFriendshipMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.userDetailsRemoveFriendSuccessMessage,
        );
        if (!context.mounted) {
          return;
        }
        context.pop();
      }
    });
    ref.listen<MutationState<FriendshipRequestListPageItemEntity>>(
      createFriendshipRequestMutation,
      (previous, next) {
        if (next is MutationError<FriendshipRequestListPageItemEntity>) {
          feedback.resolveAndShowError(context, next.error);
        } else if (next
            is MutationSuccess<FriendshipRequestListPageItemEntity>) {
          feedback.showSuccess(
            context,
            message: l10n.friendshipsRequestCreateSuccessMessage,
          );
          ref.invalidate(friendshipRequestsListProvider);
        }
      },
    );
    ref.listen<MutationState<void>>(reportUserMutation, (previous, next) {
      if (next is MutationError<void>) {
        if (_isUserReportConflictError(next.error)) {
          ref.invalidate(userReportCanCreateProvider(userId));
        }
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        ref.invalidate(userReportCanCreateProvider(userId));
        feedback.showSuccess(
          context,
          message: l10n.moderationReportSuccessMessage,
        );
      }
    });
    ref.listen<MutationState<void>>(blockUserMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.moderationBlockSuccessMessage,
        );
      }
    });
    ref.listen<MutationState<void>>(unblockUserMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      } else if (next is MutationSuccess<void>) {
        feedback.showSuccess(
          context,
          message: l10n.moderationUnblockSuccessMessage,
        );
      }
    });

    final MAppBar appBar = MAppBar(
      context: context,
      title: MAppBarTitle(
        text: userDetailsState.when<String>(
          data: (UserDetailsEntity userDetails) {
            return userDetails.name;
          },
          error: (Object _, StackTrace _) {
            return '???';
          },
          loading: () {
            return 'Florian Leeser';
          },
        ),
        isLoading: userDetailsState.isLoading,
      ),
      subtitle: MAppBarSubtitle(
        text: userDetailsState.when<String>(
          data: (UserDetailsEntity userDetails) {
            return userDetails.friendshipCode;
          },
          error: (Object _, StackTrace _) {
            return '???';
          },
          loading: () {
            return '00000000';
          },
        ),
        isLoading: userDetailsState.isLoading,
      ),
      avatar: MAppBarAvatar(
        name: userDetailsState.value?.name,
        isLoading: userDetailsState.isLoading,
      ),
      leading: <MAppBarButton>[
        MAppBarButton(
          onPressed: () => _onBack(context),
          icon: LucideIcons.arrow_left,
        ),
      ],
      trailing: <MAppBarButton>[
        MAppBarButton(
          onPressed: !isActionButtonEnabled
              ? null
              : () => _onOpenUserActions(
                  context,
                  ref,
                  l10n,
                  canUpdateName: canUpdateName,
                  canRemoveFriend: canRemoveFriend,
                  canCreateFriendRequest: canCreateFriendRequest,
                  canReportUser: canReportUser,
                  canBlockUser: canBlockUser,
                  canUnblockUser: canUnblockUser,
                  userDetails: userDetails,
                ),
          isEnabled: isActionButtonEnabled,
          isLoading: isAnyActionPending,
          icon: LucideIcons.ellipsis_vertical,
        ),
      ],
      bottom: MTabBar(
        controller: tabController,
        titles: <String>[
          l10n.userDetailsMemesTabAll,
          l10n.userDetailsMemesTabSent,
          l10n.userDetailsMemesTabReceived,
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
          children: isProfileRoute
              ? <Widget>[
                  UserDetailsOwnAllMemesListView(
                    onRefresh:
                        (
                          WidgetRef ref,
                          BuildContext context,
                          AppFeedback feedback,
                        ) =>
                            _onRefresh(ref, context, feedback, isOwnUser: true),
                  ),
                  UserDetailsOwnSentMemesListView(
                    onRefresh:
                        (
                          WidgetRef ref,
                          BuildContext context,
                          AppFeedback feedback,
                        ) =>
                            _onRefresh(ref, context, feedback, isOwnUser: true),
                  ),
                  UserDetailsOwnReceivedMemesListView(
                    onRefresh:
                        (
                          WidgetRef ref,
                          BuildContext context,
                          AppFeedback feedback,
                        ) =>
                            _onRefresh(ref, context, feedback, isOwnUser: true),
                  ),
                ]
              : <Widget>[
                  UserDetailsOtherAllMemesListView(
                    userId: userId,
                    onRefresh:
                        (
                          WidgetRef ref,
                          BuildContext context,
                          AppFeedback feedback,
                        ) => _onRefresh(
                          ref,
                          context,
                          feedback,
                          isOwnUser: false,
                        ),
                  ),
                  UserDetailsOtherSentMemesListView(
                    userId: userId,
                    onRefresh:
                        (
                          WidgetRef ref,
                          BuildContext context,
                          AppFeedback feedback,
                        ) => _onRefresh(
                          ref,
                          context,
                          feedback,
                          isOwnUser: false,
                        ),
                  ),
                  UserDetailsOtherReceivedMemesListView(
                    userId: userId,
                    onRefresh:
                        (
                          WidgetRef ref,
                          BuildContext context,
                          AppFeedback feedback,
                        ) => _onRefresh(
                          ref,
                          context,
                          feedback,
                          isOwnUser: false,
                        ),
                  ),
                ],
        ),
      ),
    );
  }
}

enum _UserDetailsAction {
  updateName,
  removeFriend,
  createFriendRequest,
  reportUser,
  blockUser,
  unblockUser,
}
