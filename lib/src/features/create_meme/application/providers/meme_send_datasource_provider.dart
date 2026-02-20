import 'package:memuno_app/src/features/create_meme/data/datasources/meme_send_datasource.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/supabase_meme_send_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'meme_send_datasource_provider.g.dart';

/// Provides the remote send-meme datasource implementation.
@Riverpod(keepAlive: true)
MemeSendDatasource memeSendDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);

  return SupabaseMemeSendDatasourceImpl(supabaseClient: supabaseClient);
}
