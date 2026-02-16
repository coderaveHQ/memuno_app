import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_client_provider.g.dart';

/// Provides the configured [SupabaseClient].
///
/// This is a keep-alive provider because it is a core dependency for:
/// - auth
/// - RPC calls
/// - storage signed URLs
@Riverpod(keepAlive: true)
SupabaseClient supabaseClient(Ref ref) {
  // Return the globally initialized Supabase client.
  return Supabase.instance.client;
}
