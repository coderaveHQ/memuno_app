import 'package:memuno_app/src/features/profile/domain/entities/user_profile_entity.dart';

/// Contract for profile-related operations for the current authenticated user.
abstract interface class ProfileRepository {
  /// Loads the current user's profile information.
  Future<UserProfileEntity> getCurrentUserProfile();

  /// Updates the current user's name.
  Future<void> updateCurrentUserName({required String name});
}
