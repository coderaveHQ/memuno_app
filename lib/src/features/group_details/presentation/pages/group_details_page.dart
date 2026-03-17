import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_tab_bar.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_memes_all_list_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_memes_sent_by_me_list_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_details_entity.dart';
import 'package:memuno_app/src/features/group_details/presentation/widgets/group_details_memes_all_list.dart';
import 'package:memuno_app/src/features/group_details/presentation/widgets/group_details_memes_sent_by_me_list.dart';

class GroupDetailsPage extends HookConsumerWidget {
  final String groupId;

  const GroupDetailsPage({super.key, required this.groupId});

  void _onBack(BuildContext context) {
    context.pop();
  }

  Future<void> _refreshLists(WidgetRef ref) {
    return Future.wait<void>(<Future<void>>[
      ref.read(groupDetailsMemesAllListProvider(groupId).notifier).refresh(),
      ref
          .read(groupDetailsMemesSentByMeListProvider(groupId).notifier)
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TabController tabController = useTabController(initialLength: 2);
    final AsyncValue<GroupDetailsEntity> groupDetailsState = ref.watch(
      groupDetailsProvider(groupId),
    );

    final MAppBar appBar = MAppBar(
      context: context,
      title: MAppBarTitle(
        text: groupDetailsState.when<String>(
          data: (GroupDetailsEntity details) => details.name,
          error: (Object _, StackTrace _) => '???',
          loading: () => l10n.groupsTitle,
        ),
      ),
      leading: <MAppBarButton>[
        MAppBarButton(
          onPressed: () => _onBack(context),
          icon: LucideIcons.arrow_left,
        ),
      ],
      trailing: <MAppBarButton>[
        MAppBarButton(
          onPressed: () {
            GroupDetailsInfoRoute(groupId: groupId).push<void>(context);
          },
          icon: LucideIcons.info,
        ),
      ],
      bottom: MTabBar(
        controller: tabController,
        titles: <String>[
          l10n.groupDetailsTabAllMemes,
          l10n.groupDetailsTabSentByMe,
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
            GroupDetailsMemesAllListView(
              groupId: groupId,
              onRefresh:
                  (WidgetRef ref, BuildContext context, AppFeedback feedback) =>
                      _onRefresh(ref, context, feedback),
            ),
            GroupDetailsMemesSentByMeListView(
              groupId: groupId,
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
