import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_direction.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/accept_friendship_request_button.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/cancel_friendship_request_button.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/decline_friendship_request_button.dart';

/// Canonical list item widget for one friendship-request row.
class MAsyncFriendshipRequestListItem extends StatelessWidget {
  const MAsyncFriendshipRequestListItem({
    super.key,
    required this.friendshipRequest,
  });

  final FriendshipRequestListPageItemEntity friendshipRequest;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MListTile(
      onPressed: () {
        UserDetailsRoute(userId: friendshipRequest.user.id).push<void>(context);
      },
      leading: MAvatar(name: friendshipRequest.user.name, dimension: 48.0),
      title: friendshipRequest.user.name,
      description:
          '${l10n.userDetailsFriendshipCodeLabel} ${friendshipRequest.user.friendshipCode}',
      details:
          friendshipRequest.direction == FriendshipRequestDirection.incoming
          ? '${l10n.friendshipsRequestDirectionIncoming}: ${friendshipRequest.createdAt.formatDateOnly(fullDate: true)}'
          : '${l10n.friendshipsRequestDirectionOutgoing}: ${friendshipRequest.createdAt.formatDateOnly(fullDate: true)}',
      trailing:
          friendshipRequest.direction == FriendshipRequestDirection.incoming
          ? Row(
              children: <Widget>[
                AcceptFriendshipRequestButton(
                  friendshipRequest: friendshipRequest,
                ),
                const MGap.sm(),
                DeclineFriendshipRequestButton(
                  friendshipRequest: friendshipRequest,
                ),
              ],
            )
          : CancelFriendshipRequestButton(friendshipRequest: friendshipRequest),
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }
}
