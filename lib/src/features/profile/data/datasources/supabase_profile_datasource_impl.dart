import 'package:memuno_app/src/features/profile/data/datasources/profile_datasource.dart';
import 'package:memuno_app/src/features/profile/data/dto/user_profile_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed profile datasource.
final class SupabaseProfileDatasourceImpl implements ProfileDatasource {
  /// Creates the datasource.
  const SupabaseProfileDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  /// Loads the current user's profile row through RPC.
  Future<UserProfileDto> getCurrentUserProfile() async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'get_current_users_profile',
    );
    if (payload is! Map) {
      throw const FormatException(
        'Expected `get_current_users_profile` to return an object payload.',
      );
    }

    return UserProfileDto.fromJson(Map<String, Object?>.from(payload));
  }

  @override
  /// Updates the current user's name via RPC.
  Future<void> updateCurrentUserName({required String name}) async {
    await _supabaseClient.rpc<void>(
      'update_current_user_name',
      params: <String, dynamic>{'p_name': name},
    );
  }
}
