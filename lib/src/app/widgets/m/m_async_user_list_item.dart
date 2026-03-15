import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_radio_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';

/// Canonical list item widget for one `user_item` row.
class MAsyncUserListItem extends StatelessWidget {
  const MAsyncUserListItem({
    super.key,
    required this.item,
    this.onPressed,
    this.isEnabled = true,
    this.showFriendshipCode = true,
    this.showSelectionIndicator = false,
    this.isSelected = false,
  });

  final UserItemEntity item;
  final void Function(UserItemEntity user)? onPressed;
  final bool isEnabled;
  final bool showFriendshipCode;
  final bool showSelectionIndicator;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MListTile(
      onPressed: onPressed == null ? null : () => onPressed!(item),
      isEnabled: isEnabled,
      leading: MAvatar(name: item.name, dimension: 48.0),
      title: item.name,
      description: showFriendshipCode
          ? '${l10n.userDetailsFriendshipCodeLabel} ${item.friendshipCode}'
          : null,
      trailing: showSelectionIndicator
          ? MRadioIndicator(isSelected: isSelected)
          : null,
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }
}
