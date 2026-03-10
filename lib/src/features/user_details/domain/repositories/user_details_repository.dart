import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';

/// Contract for user-details operations.
abstract interface class UserDetailsRepository {
  /// Loads one user's details information.
  Future<UserDetailsEntity> getUserDetails({required String userId});

  /// Updates the current user's name.
  Future<void> updateCurrentUserDetailsName({required String name});
}
