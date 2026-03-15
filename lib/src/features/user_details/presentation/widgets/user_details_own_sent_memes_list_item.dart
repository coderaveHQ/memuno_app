import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_image.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_tappable.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/user_details/application/mutations/toggle_user_details_meme_laugh_mutation.dart';
import 'package:memuno_app/src/features/user_details/application/providers/user_details_own_sent_memes_list_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_item_entity.dart';

/// Card widget for rendering one own\-sent user-details meme item.
class UserDetailsOwnSentMemesListItem extends ConsumerWidget {
  /// Creates one own\-sent user-details meme card.
  const UserDetailsOwnSentMemesListItem({super.key, required this.item});

  /// own\-sent list payload to render.
  final UserDetailsOwnSentMemesListPageItemEntity item;

  @override
  /// Builds the meme-list card UI.
  Widget build(BuildContext context, WidgetRef ref) {
    final String? currentUserId = ref.watch(currentUserProvider)?.id;
    final bool isOwnMeme = item.user.id == currentUserId;
    final bool isLiked = item.meme.isLaughed;
    final Mutation<void> mutation = ref.watch(
      toggleUserDetailsMemeLaughMutationProvider(item.meme.id),
    );
    final MutationState<void> mutationState = ref.watch(mutation);
    final AppFeedback feedback = ref.read(appFeedbackProvider);

    ref.listen<MutationState<void>>(mutation, (previous, next) {
      if (next is MutationError<void>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: MColors.gray800.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Column(
        children: <Widget>[
          Padding(
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
                    UserDetailsRoute(userId: item.user.id).push<void>(context);
                  },
                  name: item.user.name,
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
                            userId: item.user.id,
                          ).push<void>(context);
                        },
                        child: MText.h4(
                          text: item.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: MColors.gray100),
                        ),
                      ),
                      MText.small(
                        text: item.meme.createdAt.formatHumanReadable(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: MColors.gray400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const MGap.md(),
                MIconButton.primary(
                  onPressed: () => _onOpenMemeDetails(context),
                  dimension: kToolbarHeight - 4.0,
                  icon: LucideIcons.arrow_right,
                ),
              ],
            ),
          ),
          MImage.url(
            item.meme.signedImageUrl,
            aspectRatio: item.meme.aspectRatio,
          ),
          Padding(
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
                  isEnabled: !isOwnMeme && !mutationState.isPending,
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: isLiked
                          ? MColors.yellow400.withValues(alpha: 0.1)
                          : MColors.gray100,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: MSpacing.sm),
                    child: Row(
                      children: <Widget>[
                        MText.h3(text: '😂'),
                        const MGap.xs(),
                        MText.p(
                          text: '${item.meme.laughCount}',
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
        ],
      ),
    );
  }

  /// Runs an optimistic meme-laugh toggle through this list notifier.
  Future<void> _onToggleLaugh(WidgetRef ref) async {
    final Mutation<void> mutation = ref.read(
      toggleUserDetailsMemeLaughMutationProvider(item.meme.id),
    );

    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await ref
          .read(userDetailsOwnSentMemesListProvider.notifier)
          .toggleMemeLaugh(item);
    });
  }

  /// Opens the meme-details page for this meme.
  Future<void> _onOpenMemeDetails(BuildContext context) async {
    await MemeDetailsRoute(memeId: item.meme.id).push<void>(context);
  }
}
