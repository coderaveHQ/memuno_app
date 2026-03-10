import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_image.dart';
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
  static const double _memePreviewHeight = 56.0;
  static const double _minPreviewAspectRatio = 0.35;
  static const double _maxPreviewAspectRatio = 2.5;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String relativeTime = notification.notificationCreatedAt
        .formatHumanReadable();

    return MListTile(
      onPressed: () => onPressed(notification),
      leading: MAvatar(
        onPressed: () {
          UserDetailsRoute(
            userId: notification.notificationActorId,
          ).push<void>(context);
        },
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
      trailing: _buildTrailing(),
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
      NotificationType.memeLaughed => l10n.notificationsItemMemeLaughedTitle,
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
      NotificationType.memeLaughed => l10n.notificationsItemMemeLaughed(
        actorName,
      ),
    };
  }

  Widget? _buildTrailing() {
    final List<Widget> trailingChildren = <Widget>[];

    final Widget? memePreview = _buildMemePreview();
    if (memePreview != null) {
      trailingChildren.add(memePreview);
    }

    if (!notification.notificationIsRead) {
      if (trailingChildren.isNotEmpty) {
        trailingChildren.add(const MGap.sm());
      }
      trailingChildren.add(const _UnreadIndicator());
    }

    if (trailingChildren.isEmpty) {
      return null;
    }

    return Row(mainAxisSize: MainAxisSize.min, children: trailingChildren);
  }

  Widget? _buildMemePreview() {
    if (notification.notificationType != NotificationType.memeReceived &&
        notification.notificationType != NotificationType.memeLaughed) {
      return null;
    }

    final String? signedImageUrl = notification.notificationMemeSignedImageUrl;
    final double? rawAspectRatio = notification.notificationMemeAspectRatio;
    if (signedImageUrl == null ||
        signedImageUrl.isEmpty ||
        rawAspectRatio == null ||
        rawAspectRatio <= 0) {
      return null;
    }

    final double safeAspectRatio = rawAspectRatio
        .clamp(_minPreviewAspectRatio, _maxPreviewAspectRatio)
        .toDouble();

    return MImage.url(
      signedImageUrl,
      height: _memePreviewHeight,
      aspectRatio: safeAspectRatio,
    );
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
