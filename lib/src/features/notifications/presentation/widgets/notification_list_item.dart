import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_list_page_item_entity.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_type.dart';

/// Tile widget for rendering one [NotificationListPageItemEntity].
class NotificationListItem extends StatelessWidget {
  /// Creates one notification list item tile.
  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onPressed,
  });

  /// Notification payload to render.
  final NotificationListPageItemEntity notification;

  /// Callback invoked when this tile is tapped.
  final void Function(NotificationListPageItemEntity notification) onPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String relativeTime = notification.notificationCreatedAt
        .formatHumanReadable();

    return MListTile(
      onPressed: () => onPressed(notification),
      leading: MAvatar(
        name: notification.notificationActorName,
        dimension: 48.0,
      ),
      title: _titleText(l10n, notification.notificationType),
      description: _descriptionText(
        l10n,
        notification.notificationType,
        notification.notificationActorName,
      ),
      details: relativeTime,
      trailing: notification.notificationIsRead
          ? null
          : const _UnreadIndicator(),
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }

  String _titleText(AppLocalizations l10n, NotificationType type) {
    return switch (type) {
      NotificationType.friendshipRequestSent =>
        l10n.notificationsItemFriendshipRequestSentTitle,
      NotificationType.friendshipRequestAccepted =>
        l10n.notificationsItemFriendshipRequestAcceptedTitle,
      NotificationType.memeReceived => l10n.notificationsItemMemeReceivedTitle,
    };
  }

  String _descriptionText(
    AppLocalizations l10n,
    NotificationType type,
    String actorName,
  ) {
    return switch (type) {
      NotificationType.friendshipRequestSent =>
        l10n.notificationsItemFriendshipRequestSent(actorName),
      NotificationType.friendshipRequestAccepted =>
        l10n.notificationsItemFriendshipRequestAccepted(actorName),
      NotificationType.memeReceived => l10n.notificationsItemMemeReceived(
        actorName,
      ),
    };
  }
}

class _UnreadIndicator extends StatelessWidget {
  const _UnreadIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: MColors.blue400,
      ),
    );
  }
}
