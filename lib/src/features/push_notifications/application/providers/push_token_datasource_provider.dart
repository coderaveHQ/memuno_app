import 'package:memuno_app/src/features/push_notifications/data/datasources/push_token_datasource.dart';
import 'package:memuno_app/src/features/push_notifications/data/datasources/supabase_push_token_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'push_token_datasource_provider.g.dart';

/// Provides the push token datasource.
@Riverpod(keepAlive: true)
PushTokenDatasource pushTokenDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  return SupabasePushTokenDatasourceImpl(supabaseClient: supabaseClient);
}
