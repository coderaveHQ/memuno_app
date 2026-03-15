import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_own_all_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/presentation/widgets/user_details_own_all_memes_list_item.dart';

/// List view for own\-all user-details memes.
class UserDetailsOwnAllMemesListView extends StatelessWidget {
  /// Creates the list view.
  const UserDetailsOwnAllMemesListView({super.key, this.onRefresh});

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

    return MAsyncList<
      UserDetailsOwnAllMemesListPageItemEntity,
      UserDetailsOwnAllMemesCursorEntity
    >(
      provider: userDetailsOwnAllMemesListProvider,
      emptyText: l10n.userDetailsOwnAllMemesEmpty,
      loadMoreExtent: 220.0,
      onRefresh: onRefresh,
      listPadding: EdgeInsets.only(
        top: MSpacing.md,
        bottom: context.bottomPadding + MSpacing.md,
      ),
      childPadding: EdgeInsets.only(
        top: MSpacing.md,
        bottom: context.bottomPadding + MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
      ),
      separatorBuilder: (BuildContext _, int _) => const MGap.sm(),
      itemBuilder:
          (
            BuildContext context,
            UserDetailsOwnAllMemesListPageItemEntity item,
          ) {
            return UserDetailsOwnAllMemesListItem(item: item);
          },
    );
  }
}
