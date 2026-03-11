import 'package:go_router/go_router.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/core/providers/logger_provider.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notification_target_route_mapper_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notifications_unread_count_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/usecases/mark_notification_read_usecase_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/usecases/resolve_notification_push_intent_usecase_provider.dart';
import 'package:memuno_app/src/features/notifications/application/services/notification_target_route_mapper.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/resolve_notification_push_intent_usecase.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_local_notifications_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_messaging_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_platform_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_local_notifications_gateway_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_messaging_gateway_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_platform_gateway_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/services/push_notifications_intent_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_notifications_intent_service_provider.g.dart';

/// Provides the app-global push intent service.
@Riverpod(keepAlive: true)
PushNotificationsIntentService pushNotificationsIntentService(Ref ref) {
  final PushMessagingGateway pushMessagingGateway = ref.watch(
    pushMessagingGatewayProvider,
  );
  final PushPlatformGateway pushPlatformGateway = ref.watch(
    pushPlatformGatewayProvider,
  );
  final PushLocalNotificationsGateway pushLocalNotificationsGateway = ref.watch(
    pushLocalNotificationsGatewayProvider,
  );
  final ResolveNotificationPushIntentUsecase intentResolver = ref.watch(
    resolveNotificationPushIntentUsecaseProvider,
  );
  final NotificationTargetRouteMapper routeMapper = ref.watch(
    notificationTargetRouteMapperProvider,
  );
  final MarkNotificationReadUsecase markNotificationReadUsecase = ref.watch(
    markNotificationReadUsecaseProvider,
  );
  final GoRouter router = ref.watch(appRouterProvider);
  final Logger logger = ref.watch(loggerProvider);

  final PushNotificationsIntentService service = PushNotificationsIntentService(
    pushMessagingGateway: pushMessagingGateway,
    pushPlatformGateway: pushPlatformGateway,
    pushLocalNotificationsGateway: pushLocalNotificationsGateway,
    resolveNotificationPushIntentUsecase: intentResolver,
    notificationTargetRouteMapper: routeMapper,
    markNotificationReadUsecase: markNotificationReadUsecase,
    router: router,
    onUnreadCountChanged: () {
      ref.invalidate(notificationsUnreadCountProvider);
    },
    logger: logger,
  );

  ref.onDispose(service.dispose);
  return service;
}
