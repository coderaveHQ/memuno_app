import 'package:memuno_app/src/features/auth/application/providers/usecases/on_auth_state_change_usecase_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/on_auth_state_change_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_state_provider.g.dart';

/// Provides the current auth state (stream-based).
@Riverpod(keepAlive: true)
Stream<AuthStateEntity> authState(Ref ref) {
  /// Usecase that streams auth state changes.
  final OnAuthStateChangeUsecase usecase = ref.watch(
    onAuthStateChangeUsecaseProvider,
  );
  // Expose the stream directly to consumers.
  return usecase();
}
