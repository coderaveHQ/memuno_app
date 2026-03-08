import 'package:memuno_app/src/features/feed/data/datasources/feed_datasource.dart';
import 'package:memuno_app/src/features/feed/data/datasources/supabase_feed_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'feed_datasource_provider.g.dart';

/// Provides the feed datasource implementation.
@Riverpod(keepAlive: true)
FeedDatasource feedDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseFeedDatasourceImpl(supabaseClient: supabaseClient);
}
