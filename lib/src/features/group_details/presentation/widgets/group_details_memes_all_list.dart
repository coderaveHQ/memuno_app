import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_meme_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/features/group_details/application/mutations/toggle_group_details_meme_laugh_mutation.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_memes_all_list_provider.dart';

/// List view for all memes sent to one group.
class GroupDetailsMemesAllListView extends StatelessWidget {
  const GroupDetailsMemesAllListView({
    super.key,
    required this.groupId,
    this.onRefresh,
  });

  final String groupId;
  final Future<void> Function(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  )?
  onRefresh;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MAsyncMemeList(
      provider: groupDetailsMemesAllListProvider(groupId),
      emptyText: l10n.groupDetailsMemesAllEmpty,
      loadMoreExtent: 220.0,
      readToggleMutation: (WidgetRef ref, String memeId) {
        return ref.watch(toggleGroupDetailsMemeLaughMutationProvider(memeId));
      },
      onToggleLaugh: (WidgetRef ref, MemeItemEntity item) {
        return ref
            .read(groupDetailsMemesAllListProvider(groupId).notifier)
            .toggleMemeLaugh(item);
      },
      onRefresh: onRefresh,
      listPadding: EdgeInsets.only(
        top: 20.0 + MSpacing.md,
        bottom: context.bottomPadding + MSpacing.md,
      ),
      childPadding: EdgeInsets.only(
        top: 20.0 + MSpacing.md,
        bottom: context.bottomPadding + MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
      ),
      separatorBuilder: (BuildContext _, int _) => const MGap.sm(),
    );
  }
}
