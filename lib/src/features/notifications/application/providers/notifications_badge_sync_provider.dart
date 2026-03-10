import 'dart:async';

import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_user_entity.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notifications_unread_count_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/app_badge_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/app_badge_gateway_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notifications_badge_sync_provider.g.dart';

/// App-global synchronization of app-icon badge from unread notifications count.
@Riverpod(keepAlive: true)
void notificationsBadgeSync(Ref ref) {
  final AppBadgeGateway appBadgeGateway = ref.watch(appBadgeGatewayProvider);

  Future<void> applyCount(int count) {
    return appBadgeGateway.setBadgeCount(count);
  }

  ref.listen<AsyncValue<int>>(notificationsUnreadCountProvider, (
    AsyncValue<int>? previous,
    AsyncValue<int> next,
  ) {
    if (!next.hasValue) {
      return;
    }

    unawaited(applyCount(next.requireValue));
  });

  ref.listen<AuthUserEntity?>(currentUserProvider, (
    AuthUserEntity? previous,
    AuthUserEntity? next,
  ) {
    if (next != null) {
      return;
    }

    unawaited(appBadgeGateway.clearBadge());
  });

  final AsyncValue<int> initialUnreadCount = ref.read(
    notificationsUnreadCountProvider,
  );
  if (initialUnreadCount.hasValue) {
    unawaited(applyCount(initialUnreadCount.requireValue));
  }
}
