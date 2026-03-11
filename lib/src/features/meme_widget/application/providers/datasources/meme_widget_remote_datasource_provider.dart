import 'package:memuno_app/src/features/meme_widget/data/datasources/meme_widget_remote_datasource.dart';
import 'package:memuno_app/src/features/meme_widget/data/datasources/supabase_meme_widget_remote_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'meme_widget_remote_datasource_provider.g.dart';

/// Provides the remote datasource for meme widget operations.
@Riverpod(keepAlive: true)
MemeWidgetRemoteDatasource memeWidgetRemoteDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);

  return SupabaseMemeWidgetRemoteDatasourceImpl(supabaseClient: supabaseClient);
}
