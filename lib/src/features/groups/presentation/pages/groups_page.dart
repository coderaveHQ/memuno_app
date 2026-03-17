import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_tab_bar.dart';
import 'package:memuno_app/src/features/groups/presentation/widgets/group_invitations_list.dart';
import 'package:memuno_app/src/features/groups/presentation/widgets/groups_list.dart';

/// Supported initial tab values for groups route deep-links.
enum GroupsPageTab {
  /// Shows the groups list tab.
  groups(routeValue: 'groups', tabIndex: 0),

  /// Shows the invitations list tab.
  invitations(routeValue: 'invitations', tabIndex: 1);

  const GroupsPageTab({required this.routeValue, required this.tabIndex});

  /// Query-string value used in router deep-links.
  final String routeValue;

  /// Tab index used by [TabController].
  final int tabIndex;

  /// Parses route query values to a safe enum value with fallback.
  static GroupsPageTab fromRouteValue(String? rawValue) {
    return switch (rawValue) {
      'invitations' => GroupsPageTab.invitations,
      'groups' => GroupsPageTab.groups,
      _ => GroupsPageTab.groups,
    };
  }
}

/// Page showing groups and incoming invitations.
class GroupsPage extends HookConsumerWidget {
  const GroupsPage({super.key, this.initialTab = GroupsPageTab.groups});

  final GroupsPageTab initialTab;

  Future<void> _onCreateGroup(BuildContext context) async {
    await const GroupCreateNameSheetRoute().push<void>(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TabController tabController = useTabController(
      initialLength: 2,
      initialIndex: initialTab.tabIndex,
    );

    final MAppBar appBar = MAppBar(
      context: context,
      title: MAppBarTitle(text: l10n.groupsTitle),
      trailing: <MAppBarButton>[
        MAppBarButton(
          onPressed: () => unawaited(_onCreateGroup(context)),
          icon: LucideIcons.plus,
        ),
      ],
      bottom: MTabBar(
        controller: tabController,
        titles: <String>[l10n.groupsTabGroups, l10n.groupsTabInvitations],
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
            MAsyncGroupsList(
              emptyText: l10n.groupsListEmpty,
              listPadding: EdgeInsets.only(
                top: 20.0,
                bottom: context.bottomPadding,
              ),
              childPadding: EdgeInsets.only(
                top: 20.0,
                bottom: context.bottomPadding,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
              ),
            ),
            MAsyncGroupInvitationsList(
              emptyText: l10n.groupsInvitationsListEmpty,
              listPadding: EdgeInsets.only(
                top: 20.0,
                bottom: context.bottomPadding,
              ),
              childPadding: EdgeInsets.only(
                top: 20.0,
                bottom: context.bottomPadding,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
