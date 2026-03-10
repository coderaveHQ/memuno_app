import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/router/route_utils.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_refresh_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_state_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:memuno_app/src/features/friendships/application/mutations/create_friendship_request_mutation.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_requests_list_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/create_friendship_request_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/create_friendship_request_usecase.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';
import 'package:memuno_app/src/infrastructure/share_plus/share_plus_provider.dart';
import 'package:share_plus/share_plus.dart';

/// User-details page for viewing account-level user data.
class UserDetailsPage extends ConsumerWidget {
  /// Creates the user-details page.
  const UserDetailsPage({super.key, required this.userId});

  /// User id whose details are rendered.
  final String userId;

  void _onBack(BuildContext context) {
    context.pop();
  }

  Future<void> _onFriendships(BuildContext context) async {
    await const FriendshipsRoute().push<void>(context);
  }

  Future<void> _onShareFriendshipCode(
    BuildContext context,
    WidgetRef ref,
    String friendshipCode,
  ) async {
    final SharePlus sharePlus = ref.read(sharePlusProvider);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(context);

    try {
      final ShareResult _ = await sharePlus.share(
        ShareParams(
          text: l10n.userDetailsFriendshipCodeShareText(friendshipCode),
        ),
      );
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }
  }

  Future<void> _onCreateFriendshipRequest(
    WidgetRef ref,
    String friendshipCode,
  ) async {
    final Mutation<FriendshipRequestListPageItemEntity> mutation = ref.read(
      createFriendshipRequestMutationProvider,
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      final CreateFriendshipRequestUsecase usecase = tx.get(
        createFriendshipRequestUsecaseProvider,
      );
      final FriendshipRequestListPageItemEntity created = await usecase(
        addresseeFriendshipCode: friendshipCode,
      );
      ref.read(friendshipRequestsListProvider.notifier).prependRequest(created);
      return created;
    });
  }

  Future<void> _onRefresh(WidgetRef ref) async {
    final AsyncValue<UserDetailsEntity> _ = ref.refresh(
      userDetailsProvider(userId),
    );
  }

  @override
  /// Builds the page UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AsyncValue<AuthStateEntity> authState = ref.watch(authStateProvider);
    final String? currentAuthUserId = authState.value?.user?.id;
    final bool isOwnUser = currentAuthUserId == userId;
    final bool isProfileRoute = RouteUtils.isLeaf(
      context,
      CurrentUserDetailsRoute.routeName,
    );

    final AsyncValue<UserDetailsEntity> userDetailsState = ref.watch(
      userDetailsProvider(userId),
    );

    final Mutation<FriendshipRequestListPageItemEntity>
    createFriendshipRequestMutation = ref.watch(
      createFriendshipRequestMutationProvider,
    );
    final MutationState<FriendshipRequestListPageItemEntity>
    createFriendshipRequestState = ref.watch(createFriendshipRequestMutation);

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
        }
      },
    );

    final String? friendshipCode = userDetailsState.value?.friendshipCode;

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.userDetailsTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onBack(context),
            icon: LucideIcons.arrow_left,
          ),
        ],
        trailing: <MAppBarButton>[
          if (isProfileRoute)
            MAppBarButton(
              onPressed: () => _onFriendships(context),
              icon: LucideIcons.users,
            ),
          if (isProfileRoute)
            MAppBarButton(
              onPressed: () =>
                  _onShareFriendshipCode(context, ref, friendshipCode!),
              isEnabled: userDetailsState.hasValue,
              icon: LucideIcons.share,
            ),
          if (!isProfileRoute && !isOwnUser)
            MAppBarButton(
              onPressed: () => _onCreateFriendshipRequest(ref, friendshipCode!),
              isEnabled:
                  userDetailsState.hasValue &&
                  !createFriendshipRequestState.isPending,
              isLoading: createFriendshipRequestState.isPending,
              icon: LucideIcons.plus,
            ),
        ],
      ),
      body: MRefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            top: MSpacing.xs,
            bottom: context.bottomPadding + MSpacing.md,
          ),
          children: <Widget>[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MColors.gray100,
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: EdgeInsets.only(
                top: MSpacing.md,
                bottom: MSpacing.md,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MAvatar(
                        dimension: kToolbarHeight - 4.0,
                        background: MColors.gray200,
                        foreground: MColors.gray900,
                        isLoading: userDetailsState.isLoading,
                        name: userDetailsState.value?.name,
                      ),
                      const MGap.lg(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            MText.h3(
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              isLoading: userDetailsState.isLoading,
                            ),
                            const MGap.xxs(),
                            MText.small(
                              text: userDetailsState.when<String>(
                                data: (UserDetailsEntity userDetails) {
                                  return '${l10n.userDetailsJoinedAtLabel} ${userDetails.createdAt.formatDateOnly(fullDate: true)}';
                                },
                                error: (Object _, StackTrace _) {
                                  return '${l10n.userDetailsJoinedAtLabel} ???';
                                },
                                loading: () {
                                  return '${l10n.userDetailsJoinedAtLabel} ${DateTime.now().formatDateOnly(fullDate: true)}';
                                },
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              isLoading: userDetailsState.isLoading,
                            ),
                            const MGap.xxs(),
                            MText.small(
                              text: userDetailsState.when<String>(
                                data: (UserDetailsEntity userDetails) {
                                  return '${l10n.userDetailsFriendshipCodeLabel} ${userDetails.friendshipCode}';
                                },
                                error: (Object _, StackTrace _) {
                                  return '${l10n.userDetailsFriendshipCodeLabel} ???';
                                },
                                loading: () {
                                  return '${l10n.userDetailsFriendshipCodeLabel} 00000000';
                                },
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              isLoading: userDetailsState.isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
