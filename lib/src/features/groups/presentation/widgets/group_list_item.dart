import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';

/// Canonical list item widget for one group row.
class GroupListItem extends StatelessWidget {
  const GroupListItem({super.key, required this.group});

  final GroupItemEntity group;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MListTile(
      onPressed: () {
        GroupDetailsRoute(groupId: group.id).push<void>(context);
      },
      leading: MIconButton.secondary(
        icon: LucideIcons.users,
        dimension: 48.0,
        background: MColors.gray200,
        foreground: MColors.gray900,
      ),
      title: group.name,
      description: l10n.groupsMemberCount(group.memberCount),
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }
}
