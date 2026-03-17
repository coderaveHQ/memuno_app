import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_meme_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/features/user_details/application/mutations/toggle_user_details_meme_laugh_mutation.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_own_received_memes_list_provider.dart';

/// List view for own\-received user-details memes.
class UserDetailsOwnReceivedMemesListView extends StatelessWidget {
  /// Creates the list view.
  const UserDetailsOwnReceivedMemesListView({super.key, this.onRefresh});

  /// Optional custom refresh callback.
  final Future<void> Function(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  )?
  onRefresh;

  @override
  /// Builds the list UI.
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MAsyncMemeList(
      provider: userDetailsOwnReceivedMemesListProvider,
      emptyText: l10n.userDetailsOwnReceivedMemesEmpty,
      loadMoreExtent: 220.0,
      readToggleMutation: (WidgetRef ref, String memeId) {
        return ref.watch(toggleUserDetailsMemeLaughMutationProvider(memeId));
      },
      onToggleLaugh: (WidgetRef ref, MemeItemEntity item) {
        return ref
            .read(userDetailsOwnReceivedMemesListProvider.notifier)
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
