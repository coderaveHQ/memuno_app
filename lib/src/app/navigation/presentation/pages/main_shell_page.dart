import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
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

  void _onCommunity(BuildContext context) {
    const CommunityRoute().go(context);
  }

  Future<void> _onCreateMeme(BuildContext context) async {
    await const CreateRoute().push<void>(context);
  }

  @override
  Widget build(BuildContext context) {
    final String? topRouteName = GoRouterState.of(context).topRoute?.name;

    return MScaffold(
      body: navigator,
      bottomNavigationBar: MBottomNavigationBar(
        items: <MBottomNavigationBarItem>[
          MBottomNavigationBarItem(
            onPressed: () => _onFeed(context),
            icon: LucideIcons.house,
            title: 'Feed',
            isSelected: topRouteName == FeedRoute.routeName,
          ),
          MBottomNavigationBarItem(
            onPressed: () => _onCommunity(context),
            icon: LucideIcons.users,
            title: 'Community',
            isSelected: topRouteName == CommunityRoute.routeName,
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
