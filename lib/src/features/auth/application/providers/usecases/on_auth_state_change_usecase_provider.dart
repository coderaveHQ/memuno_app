import 'package:memuno_app/src/features/auth/application/providers/auth_repository_provider.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/on_auth_state_change_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'on_auth_state_change_usecase_provider.g.dart';

/// Provides the [OnAuthStateChangeUsecase] usecase.
@riverpod
OnAuthStateChangeUsecase onAuthStateChangeUsecase(Ref ref) {
  /// Repository dependency for the usecase.
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);
  // Construct the usecase with its dependencies.
  return OnAuthStateChangeUsecase(authRepository: authRepository);
}
