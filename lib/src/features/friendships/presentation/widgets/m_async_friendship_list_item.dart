import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';

/// Canonical list item widget for one friendship row.
class MAsyncFriendshipListItem extends StatelessWidget {
  const MAsyncFriendshipListItem({super.key, required this.friendship});

  final FriendshipListPageItemEntity friendship;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MListTile(
      onPressed: () {
        UserDetailsRoute(userId: friendship.user.id).push<void>(context);
      },
      leading: MAvatar(name: friendship.user.name, dimension: 48.0),
      title: friendship.user.name,
      description:
          '${l10n.userDetailsFriendshipCodeLabel} ${friendship.user.friendshipCode}',
      details:
          '${l10n.friendshipsFriendsSincePrefix}: ${friendship.createdAt.formatDateOnly(fullDate: true)}',
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }
}
