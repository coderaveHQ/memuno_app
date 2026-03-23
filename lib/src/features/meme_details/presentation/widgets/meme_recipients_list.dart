import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/mutation_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_circular_progress_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_radio_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/application/mutations/meme_recipient_remove_mutation.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/meme_recipients_list_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_item_entity.dart';

/// Callback for one successfully removed recipient row.
typedef MemeRecipientRemovedCallback = Future<void> Function(bool memeDeleted);

/// Typed async list wrapper for meme recipient targets.
class MemeRecipientsListView extends StatelessWidget {
  const MemeRecipientsListView({
    super.key,
    required this.memeId,
    required this.canEditRecipients,
    required this.onRecipientRemoved,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
  });

  final String memeId;
  final bool canEditRecipients;
  final MemeRecipientRemovedCallback onRecipientRemoved;
  final EdgeInsetsGeometry? listPadding;
  final EdgeInsetsGeometry? childPadding;
  final EdgeInsetsGeometry? listChildPadding;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MAsyncList<MemeRecipientTargetItemEntity, ListCursorEntity>(
      provider: memeRecipientsListProvider(memeId),
      emptyText: l10n.memeDetailsRecipientsEmpty,
      loadMoreExtent: 220.0,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      itemBuilder:
          (BuildContext context, MemeRecipientTargetItemEntity target) {
            return MemeRecipientListItem(
              memeId: memeId,
              target: target,
              canEditRecipients: canEditRecipients,
              onRecipientRemoved: onRecipientRemoved,
            );
          },
    );
  }
}

/// One list row for a user/group meme recipient target.
class MemeRecipientListItem extends ConsumerWidget {
  const MemeRecipientListItem({
    super.key,
    required this.memeId,
    required this.target,
    required this.canEditRecipients,
    required this.onRecipientRemoved,
  });

  final String memeId;
  final MemeRecipientTargetItemEntity target;
  final bool canEditRecipients;
  final MemeRecipientRemovedCallback onRecipientRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final String mutationKey =
        '$memeId:${target.type.databaseValue}:${target.id}';

    final Mutation<bool> removeMutation = ref.watch(
      memeRecipientRemoveMutationProvider(mutationKey),
    );
    final MutationState<bool> removeState = ref.watch(removeMutation);
    final bool isRemoving = removeState is MutationPending<bool>;

    ref.listen<MutationState<bool>>(removeMutation, (previous, next) {
      if (next is MutationError<bool>) {
        feedback.resolveAndShowError(context, next.error);
      }
    });

    final Widget leading = target.isUser
        ? MAvatar(name: target.name, dimension: 48.0)
        : MIconButton.secondary(
            icon: LucideIcons.users,
            dimension: 48.0,
            background: MColors.gray200,
            foreground: MColors.gray900,
          );

    final String description = target.isUser
        ? '${l10n.userDetailsFriendshipCodeLabel} ${target.friendshipCode ?? ''}'
        : l10n.groupsMemberCount(target.memberCount ?? 0);

    final Widget? trailing = !canEditRecipients
        ? null
        : isRemoving
        ? const MCircularProgressIndicator(dimension: 18.0)
        : const MRadioIndicator(isSelected: true);

    return MListTile(
      onPressed: canEditRecipients && !isRemoving
          ? () {
              unawaited(_removeRecipient(ref));
            }
          : null,
      isEnabled: !isRemoving,
      leading: leading,
      title: target.name,
      description: description,
      trailing: trailing,
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }

  Future<void> _removeRecipient(WidgetRef ref) async {
    final String mutationKey =
        '$memeId:${target.type.databaseValue}:${target.id}';

    final Mutation<bool> mutation = ref.read(
      memeRecipientRemoveMutationProvider(mutationKey),
    );

    final bool? memeDeleted = await mutation.runSafely(ref, (
      MutationTransaction tx,
    ) async {
      return ref
          .read(memeRecipientsListProvider(memeId).notifier)
          .removeRecipient(target);
    });

    if (memeDeleted == null) {
      return;
    }

    await onRecipientRemoved(memeDeleted);
  }
}
