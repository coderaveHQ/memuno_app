import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/push_notifications/data/datasources/push_installation_local_datasource.dart';
import 'package:memuno_app/src/features/push_notifications/data/datasources/push_token_datasource.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_platform.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_token_deactivation_reason.dart';
import 'package:memuno_app/src/features/push_notifications/domain/repositories/push_token_repository.dart';

/// Repository implementation for push token lifecycle operations.
final class PushTokenRepositoryImpl implements PushTokenRepository {
  /// Creates the repository.
  const PushTokenRepositoryImpl({
    required PushTokenDatasource pushTokenDatasource,
    required PushInstallationLocalDatasource pushInstallationLocalDatasource,
    required FailureMapper failureMapper,
  }) : _pushTokenDatasource = pushTokenDatasource,
       _pushInstallationLocalDatasource = pushInstallationLocalDatasource,
       _failureMapper = failureMapper;

  final PushTokenDatasource _pushTokenDatasource;
  final PushInstallationLocalDatasource _pushInstallationLocalDatasource;
  final FailureMapper _failureMapper;

  @override
  Future<void> upsertCurrentDeviceToken({
    required String fcmToken,
    required PushPlatform platform,
    required String languageCode,
    required String? countryCode,
  }) async {
    try {
      final String installationId = await _pushInstallationLocalDatasource
          .getOrCreateInstallationId();

      await _pushTokenDatasource.upsertToken(
        installationId: installationId,
        fcmToken: fcmToken,
        platform: platform,
        languageCode: languageCode,
        countryCode: countryCode,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> deactivateCurrentDeviceToken({
    required PushTokenDeactivationReason reason,
  }) async {
    try {
      final String? installationId = _pushInstallationLocalDatasource
          .loadInstallationId();
      if (installationId == null || installationId.isEmpty) {
        return;
      }

      await _pushTokenDatasource.deactivateCurrentDeviceToken(
        installationId: installationId,
        reason: reason,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
