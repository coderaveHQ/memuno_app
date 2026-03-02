import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_entity.dart';

/// Polymorphic entry widget for rendering one [NotificationEntity].
class NotificationListItem extends StatelessWidget {
  /// Creates a polymorphic notification list item.
  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onPressed,
  });

  /// Notification payload to render.
  final NotificationEntity notification;

  /// Callback invoked when this tile is tapped.
  final void Function(NotificationEntity notification) onPressed;

  @override
  Widget build(BuildContext context) {
    return switch (notification) {
      FriendshipRequestSentNotificationEntity value =>
        FriendshipRequestSentNotificationListItem(
          notification: value,
          onPressed: onPressed,
        ),
      FriendshipRequestAcceptedNotificationEntity value =>
        FriendshipRequestAcceptedNotificationListItem(
          notification: value,
          onPressed: onPressed,
        ),
      MemeReceivedNotificationEntity value => MemeReceivedNotificationListItem(
        notification: value,
        onPressed: onPressed,
      ),
    };
  }
}

/// Base tile used by all concrete notification item variants.
abstract class _BaseNotificationListItem<
  TNotification extends NotificationEntity
>
    extends StatelessWidget {
  /// Creates a base notification tile.
  const _BaseNotificationListItem({
    super.key,
    required this.notification,
    required this.onPressed,
  });

  /// Concrete notification payload.
  final TNotification notification;

  /// Callback invoked when this tile is tapped.
  final void Function(NotificationEntity notification) onPressed;

  /// Returns localized title text for this notification type.
  String titleText(AppLocalizations l10n);

  /// Returns localized action text for this notification type.
  String descriptionText(AppLocalizations l10n);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String relativeTime = notification.notificationCreatedAt
        .formatHumanReadable();

    return MListTile(
      onPressed: () => onPressed(notification),
      leading: MAvatar(name: notification.actorName, dimension: 48.0),
      title: titleText(l10n),
      description: descriptionText(l10n),
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
}

/// Concrete tile for `friendship_request_sent` notifications.
final class FriendshipRequestSentNotificationListItem
    extends _BaseNotificationListItem<FriendshipRequestSentNotificationEntity> {
  /// Creates the concrete tile.
  const FriendshipRequestSentNotificationListItem({
    super.key,
    required super.notification,
    required super.onPressed,
  });

  @override
  String titleText(AppLocalizations l10n) {
    return l10n.notificationsItemFriendshipRequestSentTitle;
  }

  @override
  String descriptionText(AppLocalizations l10n) {
    return l10n.notificationsItemFriendshipRequestSent(notification.actorName);
  }
}

/// Concrete tile for `friendship_request_accepted` notifications.
final class FriendshipRequestAcceptedNotificationListItem
    extends
        _BaseNotificationListItem<FriendshipRequestAcceptedNotificationEntity> {
  /// Creates the concrete tile.
  const FriendshipRequestAcceptedNotificationListItem({
    super.key,
    required super.notification,
    required super.onPressed,
  });

  @override
  String titleText(AppLocalizations l10n) {
    return l10n.notificationsItemFriendshipRequestAcceptedTitle;
  }

  @override
  String descriptionText(AppLocalizations l10n) {
    return l10n.notificationsItemFriendshipRequestAccepted(
      notification.actorName,
    );
  }
}

/// Concrete tile for `meme_received` notifications.
final class MemeReceivedNotificationListItem
    extends _BaseNotificationListItem<MemeReceivedNotificationEntity> {
  /// Creates the concrete tile.
  const MemeReceivedNotificationListItem({
    super.key,
    required super.notification,
    required super.onPressed,
  });

  @override
  String titleText(AppLocalizations l10n) {
    return l10n.notificationsItemMemeReceivedTitle;
  }

  @override
  String descriptionText(AppLocalizations l10n) {
    return l10n.notificationsItemMemeReceived(notification.actorName);
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
