import 'package:memuno_app/src/features/meme_templates/data/datasources/meme_templates_datasource.dart';
import 'package:memuno_app/src/features/meme_templates/data/datasources/supabase_meme_templates_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'meme_templates_datasource_provider.g.dart';

/// Provides the meme-templates datasource implementation.
@Riverpod(keepAlive: true)
MemeTemplatesDatasource memeTemplatesDatasource(Ref ref) {
  /// Supabase client used for RPC execution and storage URL signing.
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);

  return SupabaseMemeTemplatesDatasourceImpl(supabaseClient: supabaseClient);
}
