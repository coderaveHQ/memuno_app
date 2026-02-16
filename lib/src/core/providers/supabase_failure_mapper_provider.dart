import 'package:memuno_app/src/core/failures/supabase_failure_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'supabase_failure_mapper_provider.g.dart';

/// Provides the Supabase failure mapper.
@Riverpod(keepAlive: true)
SupabaseFailureMapper supabaseFailureMapper(Ref ref) {
  // Stateless mapper, safe to keep alive for the entire app.
  return const SupabaseFailureMapper();
}
