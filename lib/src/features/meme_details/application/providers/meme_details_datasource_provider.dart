import 'package:memuno_app/src/features/meme_details/data/datasources/meme_details_datasource.dart';
import 'package:memuno_app/src/features/meme_details/data/datasources/supabase_meme_details_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'meme_details_datasource_provider.g.dart';

/// Provides the meme-details datasource implementation.
@Riverpod(keepAlive: true)
MemeDetailsDatasource memeDetailsDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseMemeDetailsDatasourceImpl(supabaseClient: supabaseClient);
}
