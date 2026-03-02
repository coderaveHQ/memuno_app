import 'package:memuno_app/src/features/push_notifications/domain/entities/push_platform.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_token_deactivation_reason.dart';

/// Remote datasource contract for push token RPC operations.
abstract interface class PushTokenDatasource {
  /// Upserts one active token for the given installation.
  Future<void> upsertToken({
    required String installationId,
    required String fcmToken,
    required PushPlatform platform,
    required String languageCode,
    required String? countryCode,
  });

  /// Deactivates active tokens for the given installation.
  Future<void> deactivateCurrentDeviceToken({
    required String installationId,
    required PushTokenDeactivationReason reason,
  });
}
