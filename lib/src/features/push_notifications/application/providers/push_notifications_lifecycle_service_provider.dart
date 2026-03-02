import 'package:memuno_app/src/core/providers/logger_provider.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_messaging_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_platform_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_sync_state_store.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_messaging_gateway_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_platform_gateway_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/services/push_notifications_lifecycle_service.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_sync_state_store_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/usecases/deactivate_current_device_push_token_usecase_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/usecases/register_current_device_push_token_usecase_provider.dart';
import 'package:memuno_app/src/features/push_notifications/domain/usecases/deactivate_current_device_push_token_usecase.dart';
import 'package:memuno_app/src/features/push_notifications/domain/usecases/register_current_device_push_token_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_notifications_lifecycle_service_provider.g.dart';

/// Provides the app-global push notifications lifecycle service.
@Riverpod(keepAlive: true)
PushNotificationsLifecycleService pushNotificationsLifecycleService(Ref ref) {
  final PushMessagingGateway pushMessagingGateway = ref.watch(
    pushMessagingGatewayProvider,
  );
  final PushPlatformGateway pushPlatformGateway = ref.watch(
    pushPlatformGatewayProvider,
  );
  final PushSyncStateStore pushSyncStateStore = ref.watch(
    pushSyncStateStoreProvider,
  );
  final RegisterCurrentDevicePushTokenUsecase registerUsecase = ref.watch(
    registerCurrentDevicePushTokenUsecaseProvider,
  );
  final DeactivateCurrentDevicePushTokenUsecase deactivateUsecase = ref.watch(
    deactivateCurrentDevicePushTokenUsecaseProvider,
  );
  final Logger logger = ref.watch(loggerProvider);

  final PushNotificationsLifecycleService service =
      PushNotificationsLifecycleService(
        pushMessagingGateway: pushMessagingGateway,
        pushPlatformGateway: pushPlatformGateway,
        pushSyncStateStore: pushSyncStateStore,
        registerCurrentDevicePushTokenUsecase: registerUsecase,
        deactivateCurrentDevicePushTokenUsecase: deactivateUsecase,
        logger: logger,
      );

  ref.onDispose(service.dispose);
  return service;
}
