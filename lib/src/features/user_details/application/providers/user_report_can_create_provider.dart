import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'user_report_can_create_provider.g.dart';

/// Returns whether the current user can create a new active report
/// for the target user.
@riverpod
Future<bool> userReportCanCreate(Ref ref, String userId) async {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);

  final Object? payload = await supabaseClient.rpc<Object?>(
    'ugc_report_user_can_create',
    params: <String, dynamic>{'p_target_user_id': userId},
  );

  if (payload is bool) {
    return payload;
  }

  throw const FormatException(
    'Expected `ugc_report_user_can_create` to return a boolean payload.',
  );
}
