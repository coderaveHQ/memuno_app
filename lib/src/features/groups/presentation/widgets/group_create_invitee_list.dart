import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_radio_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';

/// Friend-only invitee selector used in the group-create sheet.
class GroupCreateInviteeList extends StatelessWidget {
  const GroupCreateInviteeList({
    super.key,
    required this.selectedUserIds,
    required this.onToggle,
    this.isEnabled = true,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
  });

  final Set<String> selectedUserIds;
  final ValueChanged<String> onToggle;
  final bool isEnabled;
  final EdgeInsetsGeometry? listPadding;
  final EdgeInsetsGeometry? childPadding;
  final EdgeInsetsGeometry? listChildPadding;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MAsyncList<FriendshipListPageItemEntity, FriendshipCursorEntity>(
      provider: friendshipsListProvider,
      emptyText: l10n.friendshipsListEmpty,
      loadMoreExtent: 220.0,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      itemBuilder: (BuildContext context, FriendshipListPageItemEntity friendship) {
        return MListTile(
          onPressed: isEnabled
              ? () {
                  onToggle(friendship.user.id);
                }
              : null,
          isEnabled: isEnabled,
          leading: MAvatar(name: friendship.user.name, dimension: 48.0),
          title: friendship.user.name,
          description:
              '${l10n.userDetailsFriendshipCodeLabel} ${friendship.user.friendshipCode}',
          trailing: MRadioIndicator(
            isSelected: selectedUserIds.contains(friendship.user.id),
          ),
          padding: EdgeInsets.only(
            top: MSpacing.md,
            left: context.leftPadding + MSpacing.md,
            right: context.rightPadding + MSpacing.md,
            bottom: MSpacing.md,
          ),
        );
      },
    );
  }
}
