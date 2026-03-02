import 'package:memuno_app/src/features/push_notifications/data/datasources/push_token_datasource.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_platform.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_token_deactivation_reason.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [PushTokenDatasource].
final class SupabasePushTokenDatasourceImpl implements PushTokenDatasource {
  /// Creates the datasource.
  const SupabasePushTokenDatasourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  /// Supabase client used for RPC execution.
  final SupabaseClient _supabaseClient;

  @override
  Future<void> upsertToken({
    required String installationId,
    required String fcmToken,
    required PushPlatform platform,
    required String languageCode,
    required String? countryCode,
  }) async {
    await _supabaseClient.rpc<void>(
      'push_token_upsert',
      params: <String, dynamic>{
        'p_installation_id': installationId,
        'p_fcm_token': fcmToken,
        'p_platform': platform.dbValue,
        'p_language_code': languageCode,
        'p_country_code': countryCode,
      },
    );
  }

  @override
  Future<void> deactivateCurrentDeviceToken({
    required String installationId,
    required PushTokenDeactivationReason reason,
  }) async {
    await _supabaseClient.rpc<void>(
      'push_token_deactivate_current_device',
      params: <String, dynamic>{
        'p_installation_id': installationId,
        'p_reason': reason.dbValue,
      },
    );
  }
}
