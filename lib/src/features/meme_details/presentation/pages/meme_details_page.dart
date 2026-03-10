import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_app_bar.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_center.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_progress_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_divider.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_image.dart';
import 'package:memuno_app/src/app/widgets/m/m_refresh_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_reload.dart';
import 'package:memuno_app/src/app/widgets/m/m_scaffold.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_tappable.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/meme_details/application/mutations/toggle_meme_details_laugh_mutation.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_provider.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/meme_laughs_list_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/presentation/widgets/meme_laugh_list_item.dart';

/// Page that displays one meme and all users who laughed at it.
class MemeDetailsPage extends ConsumerWidget {
  /// Creates the meme-details page.
  const MemeDetailsPage({super.key, required this.memeId});

  /// Meme id shown by this page.
  final String memeId;

  void _onBack(BuildContext context) {
    context.pop();
  }

  /// Retries loading meme details and meme-laugh list.
  Future<void> _onReload(WidgetRef ref) {
    return ref.read(memeLaughsListProvider(memeId).notifier).refresh();
  }

  /// Refreshes meme details and meme-laugh list from page 1.
  Future<void> _onRefresh(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      await ref.read(memeLaughsListProvider(memeId).notifier).refresh();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      feedback.resolveAndShowError(context, error);
    }
  }

  /// Loads next meme-laugh page if available.
  Future<void> _onLoadMore(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  ) async {
    try {
      await ref.read(memeLaughsListProvider(memeId).notifier).loadMore();
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      feedback.resolveAndShowError(context, error);
    }
  }

  /// Runs one meme-laugh toggle through the details notifier.
  Future<void> _onToggleLaugh(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      toggleMemeDetailsLaughMutationProvider(memeId),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref.read(memeDetailsProvider(memeId).notifier).toggleMemeLaugh();
      await ref.read(memeLaughsListProvider(memeId).notifier).refresh();
    });
  }

  @override
  /// Builds the page UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);

    final AsyncValue<MemeDetailsEntity> detailsState = ref.watch(
      memeDetailsProvider(memeId),
    );

    final AsyncValue<
      PaginatedListState<MemeLaughListPageItemEntity, MemeLaughCursorEntity>
    >
    laughsState = ref.watch(memeLaughsListProvider(memeId));

    final Mutation<void> toggleLaughMutation = ref.watch(
      toggleMemeDetailsLaughMutationProvider(memeId),
    );
    final MutationState<void> toggleLaughState = ref.watch(toggleLaughMutation);

    ref.listen<MutationState<void>>(toggleLaughMutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    return MScaffold(
      appBar: MAppBar(
        context: context,
        title: MAppBarTitle(text: l10n.memeDetailsTitle),
        leading: <MAppBarButton>[
          MAppBarButton(
            onPressed: () => _onBack(context),
            icon: LucideIcons.arrow_left,
          ),
        ],
      ),
      body: detailsState.when(
        data: (MemeDetailsEntity details) {
          final String? currentUserId = ref.watch(currentUserProvider)?.id;
          final bool isOwnMeme =
              currentUserId != null && details.user.id == currentUserId;
          final bool isLiked = details.isLaughed;

          return NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification notification) {
              if (notification.metrics.axis != Axis.vertical) {
                return false;
              }

              final PaginatedListState<
                MemeLaughListPageItemEntity,
                MemeLaughCursorEntity
              >?
              state = laughsState.asData?.value;

              if (state == null || !state.hasMore || state.isLoadingMore) {
                return false;
              }

              if (notification.metrics.extentAfter < 220.0) {
                unawaited(_onLoadMore(ref, context, feedback));
              }

              return false;
            },
            child: MRefreshIndicator(
              onRefresh: () => _onRefresh(ref, context, feedback),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MSpacing.md,
                        left: context.leftPadding + MSpacing.md,
                        right: context.rightPadding + MSpacing.md,
                        bottom: MSpacing.md,
                      ),
                      child: Row(
                        children: <Widget>[
                          MAvatar(
                            onPressed: () {
                              UserDetailsRoute(
                                userId: details.user.id,
                              ).push<void>(context);
                            },
                            name: details.user.name,
                            dimension: kToolbarHeight - 4.0,
                          ),
                          const MGap.md(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                MTappable(
                                  onPressed: () {
                                    UserDetailsRoute(
                                      userId: details.user.id,
                                    ).push<void>(context);
                                  },
                                  child: MText.h4(
                                    text: details.user.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: MColors.gray100,
                                    ),
                                  ),
                                ),
                                MText.small(
                                  text: details.createdAt.formatHumanReadable(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: MColors.gray400,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      width: context.screenWidth,
                      child: MImage.url(
                        details.signedImageUrl,
                        aspectRatio: details.aspectRatio,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: MSpacing.md,
                        left: context.leftPadding + MSpacing.md,
                        right: context.rightPadding + MSpacing.md,
                        bottom: MSpacing.md,
                      ),
                      child: Row(
                        children: <Widget>[
                          MTappable(
                            onPressed: () => _onToggleLaugh(ref),
                            isEnabled:
                                !isOwnMeme && !toggleLaughState.isPending,
                            child: Container(
                              height: 40.0,
                              decoration: BoxDecoration(
                                color: isLiked
                                    ? MColors.yellow400.withValues(alpha: 0.1)
                                    : MColors.gray100,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: MSpacing.sm,
                              ),
                              child: Row(
                                children: <Widget>[
                                  MText.h3(text: '😂'),
                                  const MGap.xs(),
                                  MText.p(
                                    text: '${details.laughCount}',
                                    style: TextStyle(
                                      color: isLiked
                                          ? MColors.yellow400
                                          : MColors.gray900,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: context.leftPadding + MSpacing.md,
                        right: context.rightPadding + MSpacing.md,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: MText.h4(
                          text: l10n.memeDetailsLaughsTitle,
                          style: const TextStyle(color: MColors.gray100),
                        ),
                      ),
                    ),
                  ),
                  ...laughsState.when<List<Widget>>(
                    data:
                        (
                          PaginatedListState<
                            MemeLaughListPageItemEntity,
                            MemeLaughCursorEntity
                          >
                          state,
                        ) {
                          if (state.items.isEmpty) {
                            return <Widget>[
                              SliverPadding(
                                padding: EdgeInsets.only(
                                  top: MSpacing.md,
                                  bottom: context.bottomPadding + MSpacing.md,
                                  left: context.leftPadding + MSpacing.md,
                                  right: context.rightPadding + MSpacing.md,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: MText.p(
                                      text: l10n.memeDetailsLaughsEmpty,
                                      style: TextStyle(color: MColors.gray100),
                                    ),
                                  ),
                                ),
                              ),
                            ];
                          }

                          return <Widget>[
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                                  if (index >= state.items.length) {
                                    return MCenter(
                                      padding: EdgeInsets.only(
                                        top: MSpacing.md,
                                        bottom:
                                            context.bottomPadding + MSpacing.md,
                                        left: context.leftPadding + MSpacing.md,
                                        right:
                                            context.rightPadding + MSpacing.md,
                                      ),
                                      child: const MCircularProgressIndicator(),
                                    );
                                  }

                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      if (index > 0) const MDivider(),
                                      MemeLaughListItem(
                                        item: state.items[index],
                                      ),
                                    ],
                                  );
                                },
                                childCount:
                                    state.items.length +
                                    (state.isLoadingMore ? 1 : 0),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: context.bottomPadding + MSpacing.md,
                              ),
                            ),
                          ];
                        },
                    error: (Object error, StackTrace _) {
                      return <Widget>[
                        SliverToBoxAdapter(
                          child: MReload(
                            onReload: () => _onRefresh(ref, context, feedback),
                            padding: EdgeInsets.only(
                              top: MSpacing.md,
                              bottom: context.bottomPadding + MSpacing.md,
                              left: context.leftPadding + MSpacing.md,
                              right: context.rightPadding + MSpacing.md,
                            ),
                            text: feedback.resolve(context, error),
                          ),
                        ),
                      ];
                    },
                    loading: () {
                      return <Widget>[
                        SliverToBoxAdapter(
                          child: MCenter(
                            padding: EdgeInsets.only(
                              top: MSpacing.md,
                              bottom: context.bottomPadding + MSpacing.md,
                              left: context.leftPadding + MSpacing.md,
                              right: context.rightPadding + MSpacing.md,
                            ),
                            child: const MCircularProgressIndicator(),
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          );
        },
        error: (Object error, StackTrace _) {
          final String message = feedback.resolve(context, error);
          return MReload(
            onReload: () => _onReload(ref),
            padding: EdgeInsets.only(
              top: MSpacing.md,
              bottom: context.bottomPadding + MSpacing.md,
              left: context.leftPadding + MSpacing.md,
              right: context.rightPadding + MSpacing.md,
            ),
            text: message,
          );
        },
        loading: () {
          return MCenter(
            padding: EdgeInsets.only(
              top: MSpacing.md,
              bottom: context.bottomPadding + MSpacing.md,
              left: context.leftPadding + MSpacing.md,
              right: context.rightPadding + MSpacing.md,
            ),
            child: const MCircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
