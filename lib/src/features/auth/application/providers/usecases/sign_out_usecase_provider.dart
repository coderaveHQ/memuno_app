import 'package:memuno_app/src/features/auth/application/providers/auth_repository_provider.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_out_usecase_provider.g.dart';

/// Provides the [SignOutUsecase] usecase.
@riverpod
SignOutUsecase signOutUsecase(Ref ref) {
  /// Repository dependency for the usecase.
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);
  // Construct the usecase with its dependencies.
  return SignOutUsecase(authRepository: authRepository);
}
