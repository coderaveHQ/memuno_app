import 'package:memuno_app/src/features/push_notifications/domain/entities/push_platform.dart';
import 'package:memuno_app/src/features/push_notifications/domain/repositories/push_token_repository.dart';

/// Usecase: register/upsert one token for the current installation.
final class RegisterCurrentDevicePushTokenUsecase {
  /// Creates the usecase.
  const RegisterCurrentDevicePushTokenUsecase({
    required PushTokenRepository pushTokenRepository,
  }) : _pushTokenRepository = pushTokenRepository;

  /// Repository dependency.
  final PushTokenRepository _pushTokenRepository;

  /// Registers one active token for the current installation.
  Future<void> call({
    required String fcmToken,
    required PushPlatform platform,
    required String languageCode,
    required String? countryCode,
  }) {
    return _pushTokenRepository.upsertCurrentDeviceToken(
      fcmToken: fcmToken,
      platform: platform,
      languageCode: languageCode,
      countryCode: countryCode,
    );
  }
}
