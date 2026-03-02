import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_tab_bar.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/friendship_request_dialog.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/friendship_requests_list.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/friendships_list.dart';

/// Supported initial tab values for friendships route deep-links.
enum FriendshipsPageTab {
  /// Shows the friendships list tab.
  friendships(routeValue: 'friendships', tabIndex: 0),

  /// Shows the friendship requests tab.
  requests(routeValue: 'requests', tabIndex: 1);

  const FriendshipsPageTab({required this.routeValue, required this.tabIndex});

  /// Query-string value used in router deep-links.
  final String routeValue;

  /// Tab index used by [TabController].
  final int tabIndex;

  /// Parses route query values to a safe enum value with fallback.
  static FriendshipsPageTab fromRouteValue(String? rawValue) {
    return switch (rawValue) {
      'requests' => FriendshipsPageTab.requests,
      'friendships' => FriendshipsPageTab.friendships,
      _ => FriendshipsPageTab.friendships,
    };
  }
}

/// Page showing friendships and friendship-request management.
class FriendshipsPage extends HookConsumerWidget {
  /// Creates the friendships page.
  const FriendshipsPage({
    super.key,
    this.initialTab = FriendshipsPageTab.friendships,
  });

  /// Initial tab selected when opening this page.
  final FriendshipsPageTab initialTab;

  void _onBack(BuildContext context) {
    context.pop();
  }

  /// Opens the add-friend dialog.
  Future<void> _onShowFriendshipRequestDialog(BuildContext context) async {
    await showFriendshipRequestDialog(context);
  }

  @override
  /// Builds the friendships page UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TabController tabController = useTabController(
      initialLength: 2,
      initialIndex: initialTab.tabIndex,
    );

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.friendshipsTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onBack(context),
            icon: LucideIcons.arrow_left,
          ),
        ],
        trailing: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => unawaited(_onShowFriendshipRequestDialog(context)),
            icon: LucideIcons.user_plus,
          ),
        ],
        bottom: MTabBar(
          controller: tabController,
          titles: <String>[
            l10n.friendshipsTabFriendships,
            l10n.friendshipsTabRequests,
          ],
        ),
      ),
      body: TabBarView(
        controller: tabController,
        children: <Widget>[
          const FriendshipsList(),
          const FriendshipRequestsList(),
        ],
      ),
    );
  }
}
