import 'package:memuno_app/src/features/create_meme/data/datasources/meme_recipient_targets_datasource.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/supabase_meme_recipient_targets_datasource_impl.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'meme_recipient_targets_datasource_provider.g.dart';

/// Provides the recipient-target datasource implementation.
@Riverpod(keepAlive: true)
MemeRecipientTargetsDatasource memeRecipientTargetsDatasource(Ref ref) {
  final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseMemeRecipientTargetsDatasourceImpl(
    supabaseClient: supabaseClient,
  );
}
