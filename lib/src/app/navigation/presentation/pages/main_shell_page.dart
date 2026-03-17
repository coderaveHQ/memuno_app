import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_bottom_navigation_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';

/// Root shell page that hosts tab navigation and create action.
class MainShellPage extends StatelessWidget {
  /// Nested navigator rendered inside the shell.
  final Widget navigator;

  /// Creates the main shell page.
  const MainShellPage({super.key, required this.navigator});

  void _onFeed(BuildContext context) {
    const FeedRoute().go(context);
  }

  void _onFriendships(BuildContext context) {
    const FriendshipsRoute().go(context);
  }

  void _onGroups(BuildContext context) {
    const GroupsRoute().go(context);
  }

  Future<void> _onCreateMeme(BuildContext context) async {
    await const CreateRoute().push<void>(context);
  }

  @override
  Widget build(BuildContext context) {
    final String? topRouteName = GoRouterState.of(context).topRoute?.name;
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MScaffold(
      body: navigator,
      extendBody: true,
      bottomNavigationBar: MBottomNavigationBar(
        items: <MBottomNavigationBarItem>[
          MBottomNavigationBarItem(
            onPressed: () => _onFeed(context),
            icon: LucideIcons.house,
            title: l10n.mainShellTabFeed,
            isSelected: topRouteName == FeedRoute.routeName,
          ),
          MBottomNavigationBarItem(
            onPressed: () => _onFriendships(context),
            icon: LucideIcons.contact,
            title: l10n.mainShellTabFriendships,
            isSelected: topRouteName == FriendshipsRoute.routeName,
          ),
          MBottomNavigationBarItem(
            onPressed: () => _onGroups(context),
            icon: LucideIcons.users,
            title: l10n.mainShellTabGroups,
            isSelected: topRouteName == GroupsRoute.routeName,
          ),
        ],
        action: MBottomNavigationBarAction(
          onPressed: () => _onCreateMeme(context),
          icon: LucideIcons.plus,
        ),
      ),
    );
  }
}
