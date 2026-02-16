import 'package:memuno_app/src/core/failures/app_failure_mapper.dart';
import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/failures/supabase_failure_mapper.dart';
import 'package:memuno_app/src/core/providers/supabase_failure_mapper_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'failure_mapper_provider.g.dart';

/// Provides the app-wide [FailureMapper].
@Riverpod(keepAlive: true)
FailureMapper failureMapper(Ref ref) {
  /// Mapper for Supabase-specific failures.
  final SupabaseFailureMapper supabaseFailureMapper = ref.watch(
    supabaseFailureMapperProvider,
  );
  // Compose a single mapper from all sub-mappers.
  return AppFailureMapper(supabaseFailureMapper: supabaseFailureMapper);
}
