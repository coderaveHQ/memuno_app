import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/delete_friendship_button.dart';

class FriendshipsList extends StatelessWidget {
  const FriendshipsList({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MAsyncList<FriendshipListPageItemEntity, FriendshipCursorEntity>(
      provider: friendshipsListProvider,
      emptyText: l10n.friendshipsListEmpty,
      loadMoreExtent: 220.0,
      itemBuilder: (BuildContext context, FriendshipListPageItemEntity friendship) {
        return MListTile(
          leading: MAvatar(name: friendship.user.name, dimension: 48.0),
          title: friendship.user.name,
          description:
              '${l10n.profileFriendshipCodeLabel} ${friendship.user.friendshipCode}',
          details:
              '${l10n.friendshipsFriendsSincePrefix}: ${friendship.createdAt.formatDateOnly(fullDate: true)}',
          trailing: DeleteFriendshipButton(friendship: friendship),
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
