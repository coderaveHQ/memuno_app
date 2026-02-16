import 'package:memuno_app/src/features/auth/application/providers/auth_repository_provider.dart';
import 'package:memuno_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_account_usecase_provider.g.dart';

/// Provides the [DeleteAccountUsecase] usecase.
@riverpod
DeleteAccountUsecase deleteAccountUsecase(Ref ref) {
  final AuthRepository authRepository = ref.watch(authRepositoryProvider);
  return DeleteAccountUsecase(authRepository: authRepository);
}
