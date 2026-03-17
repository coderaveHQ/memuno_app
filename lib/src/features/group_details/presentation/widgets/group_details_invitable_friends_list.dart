import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_radio_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/features/group_details/application/providers/group_details_invitable_friends_list_provider.dart';

/// Friend-only invitee selector for group-details invite flow.
class GroupDetailsInvitableFriendsList extends StatelessWidget {
  const GroupDetailsInvitableFriendsList({
    super.key,
    required this.groupId,
    required this.selectedUserIds,
    required this.onToggle,
    this.isEnabled = true,
    this.listPadding,
    this.childPadding,
    this.listChildPadding,
  });

  final String groupId;
  final Set<String> selectedUserIds;
  final ValueChanged<String> onToggle;
  final bool isEnabled;
  final EdgeInsetsGeometry? listPadding;
  final EdgeInsetsGeometry? childPadding;
  final EdgeInsetsGeometry? listChildPadding;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MAsyncList<UserItemEntity, ListCursorEntity>(
      provider: groupDetailsInvitableFriendsListProvider(groupId),
      emptyText: l10n.groupDetailsInviteMembersEmpty,
      loadMoreExtent: 220.0,
      listPadding: listPadding,
      childPadding: childPadding,
      listChildPadding: listChildPadding,
      itemBuilder: (BuildContext context, UserItemEntity user) {
        return MListTile(
          onPressed: isEnabled
              ? () {
                  onToggle(user.id);
                }
              : null,
          isEnabled: isEnabled,
          leading: MAvatar(name: user.name, dimension: 48.0),
          title: user.name,
          description:
              '${l10n.userDetailsFriendshipCodeLabel} ${user.friendshipCode}',
          trailing: MRadioIndicator(
            isSelected: selectedUserIds.contains(user.id),
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
