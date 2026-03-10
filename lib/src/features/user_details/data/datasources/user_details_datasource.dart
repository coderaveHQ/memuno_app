import 'package:memuno_app/src/features/user_details/data/dto/user_details_dto.dart';

/// Low-level datasource for user-details data operations.
abstract interface class UserDetailsDatasource {
  /// Loads one user-details row by user id.
  Future<UserDetailsDto> getUserDetails({required String userId});

  /// Updates the current user's name through an RPC call.
  Future<void> updateCurrentUserDetailsName({required String name});
}
