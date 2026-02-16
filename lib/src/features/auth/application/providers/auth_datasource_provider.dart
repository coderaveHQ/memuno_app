import 'package:memuno_app/src/features/auth/data/datasources/auth_datasource.dart';
import 'package:memuno_app/src/features/auth/data/datasources/supabase_auth_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_datasource_provider.g.dart';

/// Provides the [AuthDatasource].
@Riverpod(keepAlive: true)
AuthDatasource authDatasource(Ref ref) {
  /// Supabase client used by the datasource.
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  // Use the Supabase-backed datasource implementation.
  return SupabaseAuthDatasourceImpl(supabaseClient: supabaseClient);
}
