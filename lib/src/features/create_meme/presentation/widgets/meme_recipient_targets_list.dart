import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_radio_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_recipient_targets_list_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

/// Typed async list wrapper for polymorphic meme recipient targets.
class MAsyncMemeRecipientTargetsList extends StatelessWidget {
  const MAsyncMemeRecipientTargetsList({
    super.key,
    this.provider,
    required this.emptyText,
    required this.selectedUserIds,
    required this.selectedGroupIds,
    required this.onToggleSelection,
    this.loadMoreExtent = 220.0,
    this.isSelectionEnabled = true,
    this.onRefresh,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
  });

  final $AsyncNotifierProvider<
    dynamic,
    PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>
  >?
  provider;
  final String emptyText;
  final Set<String> selectedUserIds;
  final Set<String> selectedGroupIds;
  final ValueChanged<MemeRecipientTargetItemEntity> onToggleSelection;
  final double loadMoreExtent;
  final bool isSelectionEnabled;
  final Future<void> Function(
    WidgetRef ref,
    BuildContext context,
    AppFeedback feedback,
  )?
  onRefresh;
  final EdgeInsetsGeometry? listPadding;
  final EdgeInsetsGeometry? childPadding;
  final EdgeInsetsGeometry? listChildPadding;

  @override
  Widget build(BuildContext context) {
    return MAsyncList<MemeRecipientTargetItemEntity, ListCursorEntity>(
      provider: provider ?? memeRecipientTargetsListProvider,
      emptyText: emptyText,
      loadMoreExtent: loadMoreExtent,
      onRefresh: onRefresh,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      itemBuilder:
          (
            BuildContext context,
            MemeRecipientTargetItemEntity recipientTarget,
          ) {
            final bool isSelected = recipientTarget.isUser
                ? selectedUserIds.contains(recipientTarget.id)
                : selectedGroupIds.contains(recipientTarget.id);

            return MemeRecipientTargetListItem(
              recipientTarget: recipientTarget,
              isSelected: isSelected,
              isSelectionEnabled: isSelectionEnabled,
              onToggleSelection: () {
                onToggleSelection(recipientTarget);
              },
            );
          },
    );
  }
}

/// Canonical list item widget for one polymorphic recipient target row.
class MemeRecipientTargetListItem extends StatelessWidget {
  const MemeRecipientTargetListItem({
    super.key,
    required this.recipientTarget,
    required this.isSelected,
    required this.onToggleSelection,
    required this.isSelectionEnabled,
  });

  final MemeRecipientTargetItemEntity recipientTarget;
  final bool isSelected;
  final VoidCallback onToggleSelection;
  final bool isSelectionEnabled;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final Widget leading = recipientTarget.isUser
        ? MAvatar(name: recipientTarget.name, dimension: 48.0)
        : MIconButton.secondary(
            icon: LucideIcons.users,
            dimension: 48.0,
            background: MColors.gray200,
            foreground: MColors.gray900,
          );

    final String description = recipientTarget.isUser
        ? '${l10n.userDetailsFriendshipCodeLabel} ${recipientTarget.friendshipCode ?? ''}'
        : l10n.groupsMemberCount(recipientTarget.memberCount ?? 0);

    return MListTile(
      onPressed: isSelectionEnabled ? onToggleSelection : null,
      isEnabled: isSelectionEnabled,
      leading: leading,
      title: recipientTarget.name,
      description: description,
      trailing: MRadioIndicator(isSelected: isSelected),
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }
}
