import 'package:memuno_app/src/features/push_notifications/domain/entities/push_platform.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_token_deactivation_reason.dart';

/// Contract for push-token lifecycle operations.
abstract interface class PushTokenRepository {
  /// Upserts one active token for the current device installation.
  Future<void> upsertCurrentDeviceToken({
    required String fcmToken,
    required PushPlatform platform,
    required String languageCode,
    required String? countryCode,
  });

  /// Soft-deactivates active tokens for the current device installation.
  Future<void> deactivateCurrentDeviceToken({
    required PushTokenDeactivationReason reason,
  });
}
