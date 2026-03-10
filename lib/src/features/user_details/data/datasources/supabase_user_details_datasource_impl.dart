import 'package:memuno_app/src/features/user_details/data/datasources/user_details_datasource.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed user-details datasource.
final class SupabaseUserDetailsDatasourceImpl implements UserDetailsDatasource {
  /// Creates the datasource.
  const SupabaseUserDetailsDatasourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  /// Loads one user's details row through RPC.
  Future<UserDetailsDto> getUserDetails({required String userId}) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'get_users_profile',
      params: <String, dynamic>{'p_user_id': userId},
    );
    if (payload is! Map) {
      throw const FormatException(
        'Expected `get_users_profile` to return an object payload.',
      );
    }

    return UserDetailsDto.fromJson(Map<String, Object?>.from(payload));
  }

  @override
  /// Updates the current user's name via RPC.
  Future<void> updateCurrentUserDetailsName({required String name}) async {
    await _supabaseClient.rpc<void>(
      'update_current_user_name',
      params: <String, dynamic>{'p_name': name},
    );
  }
}
