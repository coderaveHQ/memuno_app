import 'package:memuno_app/src/features/profile/data/datasources/profile_datasource.dart';
import 'package:memuno_app/src/features/profile/data/datasources/supabase_profile_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profile_datasource_provider.g.dart';

/// Provides the profile datasource.
@Riverpod(keepAlive: true)
ProfileDatasource profileDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseProfileDatasourceImpl(supabaseClient: supabaseClient);
}
