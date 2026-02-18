import 'package:memuno_app/src/features/profile/domain/entities/user_profile_entity.dart';
import 'package:memuno_app/src/features/profile/domain/repositories/profile_repository.dart';

/// Loads profile data for the currently authenticated user.
final class GetCurrentUserProfileUsecase {
  /// Creates the usecase.
  const GetCurrentUserProfileUsecase({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;

  /// Executes the read operation.
  Future<UserProfileEntity> call() {
    return _repository.getCurrentUserProfile();
  }
}
