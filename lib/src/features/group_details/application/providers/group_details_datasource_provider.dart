import 'package:memuno_app/src/features/group_details/data/datasources/group_details_datasource.dart';
import 'package:memuno_app/src/features/group_details/data/datasources/supabase_group_details_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'group_details_datasource_provider.g.dart';

/// Provides the group-details datasource implementation.
@Riverpod(keepAlive: true)
GroupDetailsDatasource groupDetailsDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseGroupDetailsDatasourceImpl(supabaseClient: supabaseClient);
}
