import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_item_entity.dart';
import 'package:memuno_app/src/features/groups/presentation/widgets/group_invitation_accept_button.dart';
import 'package:memuno_app/src/features/groups/presentation/widgets/group_invitation_reject_button.dart';

/// Canonical list item widget for one incoming group invitation row.
class GroupInvitationListItem extends StatelessWidget {
  const GroupInvitationListItem({super.key, required this.invitation});

  final GroupInvitationItemEntity invitation;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MListTile(
      onPressed: () {
        GroupDetailsRoute(groupId: invitation.group.id).push<void>(context);
      },
      leading: MIconButton.secondary(
        icon: LucideIcons.users,
        dimension: 48.0,
        background: MColors.gray200,
        foreground: MColors.gray900,
      ),
      title: invitation.group.name,
      description: l10n.groupsInvitationFrom(
        invitation.inviter.name,
        invitation.inviter.friendshipCode,
      ),
      details:
          '${l10n.groupsMemberCount(invitation.group.memberCount)} • '
          '${invitation.createdAt.formatDateOnly(fullDate: true)}',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GroupInvitationAcceptButton(invitation: invitation),
          const MGap.sm(),
          GroupInvitationRejectButton(invitation: invitation),
        ],
      ),
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }
}
