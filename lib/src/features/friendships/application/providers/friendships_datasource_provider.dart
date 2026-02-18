import 'package:memuno_app/src/features/friendships/data/datasources/friendships_datasource.dart';
import 'package:memuno_app/src/features/friendships/data/datasources/supabase_friendships_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'friendships_datasource_provider.g.dart';

/// Provides the friendships datasource implementation.
@Riverpod(keepAlive: true)
FriendshipsDatasource friendshipsDatasource(Ref ref) {
  /// Supabase client used for RPC execution.
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);

  return SupabaseFriendshipsDatasourceImpl(supabaseClient: supabaseClient);
}
