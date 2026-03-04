import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_async_list.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendship_requests_list_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_direction.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/accept_friendship_request_button.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/cancel_friendship_request_button.dart';
import 'package:memuno_app/src/features/friendships/presentation/widgets/decline_friendship_request_button.dart';

class FriendshipRequestsList extends ConsumerWidget {
  const FriendshipRequestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MAsyncList<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >(
      provider: friendshipRequestsListProvider,
      emptyText: l10n.friendshipsRequestsListEmpty,
      loadMoreExtent: 220.0,
      itemBuilder:
          (
            BuildContext context,
            FriendshipRequestListPageItemEntity friendshipRequest,
          ) {
            return MListTile(
              leading: MAvatar(
                name: friendshipRequest.user.name,
                dimension: 48.0,
              ),
              title: friendshipRequest.user.name,
              description:
                  '${l10n.profileFriendshipCodeLabel} ${friendshipRequest.user.friendshipCode}',
              details:
                  friendshipRequest.direction ==
                      FriendshipRequestDirection.incoming
                  ? '${l10n.friendshipsRequestDirectionIncoming}: ${friendshipRequest.createdAt.formatDateOnly(fullDate: true)}'
                  : '${l10n.friendshipsRequestDirectionOutgoing}: ${friendshipRequest.createdAt.formatDateOnly(fullDate: true)}',
              trailing:
                  friendshipRequest.direction ==
                      FriendshipRequestDirection.incoming
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
                  : CancelFriendshipRequestButton(
                      friendshipRequest: friendshipRequest,
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
