import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/profile/data/datasources/profile_datasource.dart';
import 'package:memuno_app/src/features/profile/data/dto/user_profile_dto.dart';
import 'package:memuno_app/src/features/profile/data/mappers/user_profile_mapper.dart';
import 'package:memuno_app/src/features/profile/domain/entities/user_profile_entity.dart';
import 'package:memuno_app/src/features/profile/domain/repositories/profile_repository.dart';

/// Repository implementation for current-user profile operations.
final class ProfileRepositoryImpl implements ProfileRepository {
  /// Creates the repository.
  const ProfileRepositoryImpl({
    required ProfileDatasource profileDatasource,
    required UserProfileMapper userProfileMapper,
    required FailureMapper failureMapper,
  }) : _profileDatasource = profileDatasource,
       _userProfileMapper = userProfileMapper,
       _failureMapper = failureMapper;

  final ProfileDatasource _profileDatasource;
  final UserProfileMapper _userProfileMapper;
  final FailureMapper _failureMapper;

  @override
  /// Loads and maps the current user profile.
  Future<UserProfileEntity> getCurrentUserProfile() async {
    try {
      final UserProfileDto dto = await _profileDatasource
          .getCurrentUserProfile();
      return _userProfileMapper.toDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Updates the current user's name.
  Future<void> updateCurrentUserName({required String name}) async {
    try {
      await _profileDatasource.updateCurrentUserName(name: name);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
