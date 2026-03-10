import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/user_details/data/datasources/user_details_datasource.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_dto.dart';
import 'package:memuno_app/src/features/user_details/data/mappers/user_details_mapper.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/repositories/user_details_repository.dart';

/// Repository implementation for user-details operations.
final class UserDetailsRepositoryImpl implements UserDetailsRepository {
  /// Creates the repository.
  const UserDetailsRepositoryImpl({
    required UserDetailsDatasource userDetailsDatasource,
    required UserDetailsMapper userDetailsMapper,
    required FailureMapper failureMapper,
  }) : _userDetailsDatasource = userDetailsDatasource,
       _userDetailsMapper = userDetailsMapper,
       _failureMapper = failureMapper;

  final UserDetailsDatasource _userDetailsDatasource;
  final UserDetailsMapper _userDetailsMapper;
  final FailureMapper _failureMapper;

  @override
  /// Loads and maps one user's details.
  Future<UserDetailsEntity> getUserDetails({required String userId}) async {
    try {
      final UserDetailsDto dto = await _userDetailsDatasource.getUserDetails(
        userId: userId,
      );
      return _userDetailsMapper.toDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Updates the current user's name.
  Future<void> updateCurrentUserDetailsName({required String name}) async {
    try {
      await _userDetailsDatasource.updateCurrentUserDetailsName(name: name);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
