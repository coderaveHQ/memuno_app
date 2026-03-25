import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_block_status_provider.g.dart';

/// Returns whether the current user has blocked the target user.
@riverpod
Future<bool> userBlockStatus(Ref ref, String userId) async {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);

  final Object? payload = await supabaseClient.rpc<Object?>(
    'user_is_blocked',
    params: <String, dynamic>{'p_target_user_id': userId},
  );

  if (payload is bool) {
    return payload;
  }

  throw const FormatException(
    'Expected `user_is_blocked` to return a boolean payload.',
  );
}
