import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/router/route_utils.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_tab_bar.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_other_all_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_other_received_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_other_sent_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_own_all_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_own_received_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_own_sent_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/update_current_user_details_name_dialog.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_other_all_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_other_received_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_other_sent_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_own_all_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_own_received_memes_list.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_own_sent_memes_list.dart';

/// User-details page for viewing account-level user data.
class UserDetailsPage extends HookConsumerWidget {
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

  @override
  /// Builds the page UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TabController tabController = useTabController(initialLength: 3);
    final bool isProfileRoute = RouteUtils.isLeaf(
      context,
      CurrentUserDetailsRoute.routeName,
    );

    final AsyncValue<UserDetailsEntity> userDetailsState = ref.watch(
      userDetailsProvider(userId),
    );

    return MScaffold(
      appBar: MAppBar(
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
          if (isProfileRoute)
            MAppBarButton(
              onPressed: () => _onUpdateName(
                context,
                initialName: userDetailsState.value!.name,
              ),
              isEnabled: userDetailsState.hasValue,
              icon: LucideIcons.pencil,
            ),
          if (isProfileRoute)
            MAppBarButton(
              onPressed: () => _onFriendships(context),
              icon: LucideIcons.users,
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
      ),
      body: TabBarView(
        controller: tabController,
        children: isProfileRoute
            ? <Widget>[
                UserDetailsOwnAllMemesListView(
                  onRefresh:
                      (
                        WidgetRef ref,
                        BuildContext context,
                        AppFeedback feedback,
                      ) => _onRefresh(ref, context, feedback, isOwnUser: true),
                ),
                UserDetailsOwnSentMemesListView(
                  onRefresh:
                      (
                        WidgetRef ref,
                        BuildContext context,
                        AppFeedback feedback,
                      ) => _onRefresh(ref, context, feedback, isOwnUser: true),
                ),
                UserDetailsOwnReceivedMemesListView(
                  onRefresh:
                      (
                        WidgetRef ref,
                        BuildContext context,
                        AppFeedback feedback,
                      ) => _onRefresh(ref, context, feedback, isOwnUser: true),
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
                      ) => _onRefresh(ref, context, feedback, isOwnUser: false),
                ),
                UserDetailsOtherSentMemesListView(
                  userId: userId,
                  onRefresh:
                      (
                        WidgetRef ref,
                        BuildContext context,
                        AppFeedback feedback,
                      ) => _onRefresh(ref, context, feedback, isOwnUser: false),
                ),
                UserDetailsOtherReceivedMemesListView(
                  userId: userId,
                  onRefresh:
                      (
                        WidgetRef ref,
                        BuildContext context,
                        AppFeedback feedback,
                      ) => _onRefresh(ref, context, feedback, isOwnUser: false),
                ),
              ],
      ),
    );
  }
}
