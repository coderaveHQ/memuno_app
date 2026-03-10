import 'package:memuno_app/src/features/user_details/data/datasources/supabase_user_details_datasource_impl.dart';
import 'package:memuno_app/src/features/user_details/data/datasources/user_details_datasource.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_details_datasource_provider.g.dart';

/// Provides the user-details datasource.
@Riverpod(keepAlive: true)
UserDetailsDatasource userDetailsDatasource(Ref ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseUserDetailsDatasourceImpl(supabaseClient: supabaseClient);
}
