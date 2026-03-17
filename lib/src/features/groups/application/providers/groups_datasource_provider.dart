import 'package:memuno_app/src/features/groups/data/datasources/groups_datasource.dart';
import 'package:memuno_app/src/features/groups/data/datasources/supabase_groups_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'groups_datasource_provider.g.dart';

/// Provides the groups datasource implementation.
@Riverpod(keepAlive: true)
GroupsDatasource groupsDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseGroupsDatasourceImpl(supabaseClient: supabaseClient);
}
