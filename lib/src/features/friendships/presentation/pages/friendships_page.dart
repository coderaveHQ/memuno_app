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

/// Page showing friendships and friendship-request management.
class FriendshipsPage extends HookConsumerWidget {
  /// Creates the friendships page.
  const FriendshipsPage({super.key});

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
    final TabController tabController = useTabController(initialLength: 2);

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
