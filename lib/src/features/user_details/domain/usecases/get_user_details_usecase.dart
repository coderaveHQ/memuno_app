import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Loads details data for one user id.
final class GetUserDetailsUsecase {
  /// Creates the usecase.
  const GetUserDetailsUsecase({required UserDetailsRepository repository})
    : _repository = repository;

  final UserDetailsRepository _repository;

  /// Executes the read operation.
  Future<UserDetailsEntity> call({required String userId}) {
    return _repository.getUserDetails(userId: userId);
  }
}
