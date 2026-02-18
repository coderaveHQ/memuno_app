import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_progress_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_divider.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_refresh_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_reload.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_tappable.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_entity.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/delete_friendship_button.dart';

class FriendshipsList extends ConsumerWidget {
  const FriendshipsList({super.key});

  Future<void> _onRefresh(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      await ref.read(friendshipsListProvider.notifier).refresh();
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }
  }

  Future<void> _onLoadMore(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      await ref.read(friendshipsListProvider.notifier).loadMore();
    } catch (error) {
      if (!context.mounted) return;
      feedback.resolveAndShowError(context, error);
    }
  }

  int _itemCount(
    PaginatedListState<FriendshipEntity, FriendshipCursorEntity> state,
  ) {
    if (state.items.isEmpty) {
      return 1;
    }

    final bool showTail = state.isLoadingMore || state.hasMore;
    return state.items.length + (showTail ? 1 : 0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final EdgeInsets paddingWithoutBottom = EdgeInsets.only(
      top: MSpacing.md,
      bottom: MSpacing.md,
      left: context.leftPadding + MSpacing.md,
      right: context.rightPadding + MSpacing.md,
    );
    final EdgeInsets paddingWithBottom = paddingWithoutBottom.copyWith(
      bottom: context.bottomPadding + MSpacing.md,
    );

    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AsyncValue<
      PaginatedListState<FriendshipEntity, FriendshipCursorEntity>
    >
    asyncFriendships = ref.watch(friendshipsListProvider);

    return asyncFriendships.when(
      data:
          (
            PaginatedListState<FriendshipEntity, FriendshipCursorEntity>
            friendshipsState,
          ) {
            final List<FriendshipEntity> friendships = friendshipsState.items;
            return NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.extentAfter < 220.0) {
                  unawaited(_onLoadMore(ref, context, feedback));
                }
                return false;
              },
              child: MRefreshIndicator(
                onRefresh: () => _onRefresh(ref, context, feedback),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _itemCount(friendshipsState),
                  padding: EdgeInsets.only(bottom: context.bottomPadding),
                  separatorBuilder: (BuildContext context, int index) {
                    return const MDivider();
                  },
                  itemBuilder: (BuildContext context, int index) {
                    if (friendships.isEmpty) {
                      return MReload(
                        onReload: () => _onRefresh(ref, context, feedback),
                        padding: paddingWithoutBottom,
                        text: l10n.friendshipsListEmpty,
                      );
                    }

                    if (index >= friendships.length) {
                      if (!friendshipsState.isLoadingMore) {
                        return const MGap.md();
                      }

                      return MCenter(
                        padding: paddingWithoutBottom,
                        child: MCircularProgressIndicator(
                          color: MColors.gray100,
                        ),
                      );
                    }

                    final FriendshipEntity friendship = friendships[index];

                    return MTappable(
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MSpacing.lg,
                          left: context.leftPadding + MSpacing.md,
                          right: context.rightPadding + MSpacing.md,
                          bottom: MSpacing.md,
                        ),
                        child: Row(
                          children: <Widget>[
                            MAvatar(
                              name: friendship.user.name,
                              dimension: 48.0,
                            ),
                            const MGap.md(),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  MText.h4(
                                    text: friendship.user.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: MColors.gray100),
                                  ),
                                  const MGap.xxs(),
                                  MText.small(
                                    text:
                                        '${l10n.friendshipsFriendsSincePrefix}: ${friendship.createdAt.formatDateOnly(fullDate: true)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: MColors.gray400),
                                  ),
                                ],
                              ),
                            ),
                            const MGap.md(),
                            DeleteFriendshipButton(friendship: friendship),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
      error: (Object e, StackTrace _) {
        final String message = feedback.resolve(context, e);
        return MReload(
          onReload: () => _onRefresh(ref, context, feedback),
          padding: paddingWithBottom,
          text: message,
        );
      },
      loading: () {
        return MCenter(
          padding: paddingWithBottom,
          child: MCircularProgressIndicator(color: MColors.gray100),
        );
      },
    );
  }
}
