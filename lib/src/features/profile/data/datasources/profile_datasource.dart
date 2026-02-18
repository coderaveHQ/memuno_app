import 'package:memuno_app/src/features/profile/data/dto/user_profile_dto.dart';

/// Low-level datasource for profile data operations.
abstract interface class ProfileDatasource {
  /// Loads the current user profile row.
  Future<UserProfileDto> getCurrentUserProfile();

  /// Updates the current user name through an RPC call.
  Future<void> updateCurrentUserName({required String name});
}
