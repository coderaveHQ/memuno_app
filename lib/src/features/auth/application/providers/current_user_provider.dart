import 'package:memuno_app/src/features/auth/application/providers/auth_state_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_user_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_provider.g.dart';

/// Provides the current authenticated user (null if not signed in).
@riverpod
AuthUserEntity? currentUser(Ref ref) {
  /// Stream-backed auth state provider.
  final AsyncValue<AuthStateEntity> authState = ref.watch(authStateProvider);
  // Extract the current user when state is available.
  return authState.maybeWhen(
    data: (AuthStateEntity state) => state.user,
    orElse: () => null,
  );
}
