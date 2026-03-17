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
import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';

typedef MAsyncMemeMutationReader =
    Mutation<void> Function(WidgetRef ref, String memeId);

typedef MAsyncMemeToggleHandler =
    Future<void> Function(WidgetRef ref, MemeItemEntity meme);

typedef MAsyncMemeOpenUserHandler =
    Future<void> Function(BuildContext context, String userId);

typedef MAsyncMemeOpenDetailsHandler =
    Future<void> Function(BuildContext context, String memeId);

/// Reusable canonical card for one `meme_item` list row.
class MAsyncMemeListItem extends ConsumerWidget {
  const MAsyncMemeListItem({
    super.key,
    required this.item,
    required this.readToggleMutation,
    required this.onToggleLaugh,
    this.onOpenUserDetails,
    this.onOpenMemeDetails,
  });

  final MemeItemEntity item;
  final MAsyncMemeMutationReader readToggleMutation;
  final MAsyncMemeToggleHandler onToggleLaugh;
  final MAsyncMemeOpenUserHandler? onOpenUserDetails;
  final MAsyncMemeOpenDetailsHandler? onOpenMemeDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String? currentUserId = ref.watch(currentUserProvider)?.id;
    final bool isOwnMeme = item.user.id == currentUserId;
    final bool isLaughed = item.isLaughed;
    final Mutation<void> mutation = readToggleMutation(ref, item.id);
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
                  onPressed: () => _openUserDetails(context, item.user.id),
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
                        onPressed: () =>
                            _openUserDetails(context, item.user.id),
                        child: MText.h4(
                          text: item.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: MColors.gray100),
                        ),
                      ),
                      MText.small(
                        text: item.createdAt.formatHumanReadable(),
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
                const MGap.md(),
                MIconButton.primary(
                  onPressed: () => _openMemeDetails(context, item.id),
                  dimension: kToolbarHeight - 4.0,
                  icon: LucideIcons.arrow_right,
                ),
              ],
            ),
          ),
          MImage.url(item.signedImageUrl, aspectRatio: item.aspectRatio),
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
                  onPressed: () => _toggleLaugh(ref),
                  isEnabled: !isOwnMeme && !mutationState.isPending,
                  child: Container(
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: isLaughed
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
                          text: '${item.laughCount}',
                          style: TextStyle(
                            color: isLaughed
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

  Future<void> _toggleLaugh(WidgetRef ref) async {
    final Mutation<void> mutation = readToggleMutation(ref, item.id);
    await mutation.runSafely(ref, (MutationTransaction tx) async {
      await onToggleLaugh(ref, item);
    });
  }

  Future<void> _openUserDetails(BuildContext context, String userId) async {
    if (onOpenUserDetails != null) {
      await onOpenUserDetails!(context, userId);
      return;
    }
    await UserDetailsRoute(userId: userId).push<void>(context);
  }

  Future<void> _openMemeDetails(BuildContext context, String memeId) async {
    if (onOpenMemeDetails != null) {
      await onOpenMemeDetails!(context, memeId);
      return;
    }
    await MemeDetailsRoute(memeId: memeId).push<void>(context);
  }
}
