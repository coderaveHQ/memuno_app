import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/user_details/data/datasources/user_details_datasource.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_sent_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/mappers/user_details_mapper.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_cursor_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_entity.dart';
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

  @override
  /// Loads and maps one own-all user-details memes page.
  Future<UserDetailsOwnAllMemesListPageEntity> listUserDetailsOwnAllMemes({
    required int limit,
    UserDetailsOwnAllMemesCursorEntity? cursor,
  }) async {
    try {
      final UserDetailsOwnAllMemesListPageDto dto = await _userDetailsDatasource
          .listUserDetailsOwnAllMemes(
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _userDetailsMapper.ownAllPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads and maps one own-sent user-details memes page.
  Future<UserDetailsOwnSentMemesListPageEntity> listUserDetailsOwnSentMemes({
    required int limit,
    UserDetailsOwnSentMemesCursorEntity? cursor,
  }) async {
    try {
      final UserDetailsOwnSentMemesListPageDto dto =
          await _userDetailsDatasource.listUserDetailsOwnSentMemes(
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _userDetailsMapper.ownSentPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads and maps one own-received user-details memes page.
  Future<UserDetailsOwnReceivedMemesListPageEntity>
  listUserDetailsOwnReceivedMemes({
    required int limit,
    UserDetailsOwnReceivedMemesCursorEntity? cursor,
  }) async {
    try {
      final UserDetailsOwnReceivedMemesListPageDto dto =
          await _userDetailsDatasource.listUserDetailsOwnReceivedMemes(
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _userDetailsMapper.ownReceivedPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads and maps one other-all user-details memes page.
  Future<UserDetailsOtherAllMemesListPageEntity> listUserDetailsOtherAllMemes({
    required String userId,
    required int limit,
    UserDetailsOtherAllMemesCursorEntity? cursor,
  }) async {
    try {
      final UserDetailsOtherAllMemesListPageDto dto =
          await _userDetailsDatasource.listUserDetailsOtherAllMemes(
            userId: userId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _userDetailsMapper.otherAllPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads and maps one other-sent user-details memes page.
  Future<UserDetailsOtherSentMemesListPageEntity>
  listUserDetailsOtherSentMemes({
    required String userId,
    required int limit,
    UserDetailsOtherSentMemesCursorEntity? cursor,
  }) async {
    try {
      final UserDetailsOtherSentMemesListPageDto dto =
          await _userDetailsDatasource.listUserDetailsOtherSentMemes(
            userId: userId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _userDetailsMapper.otherSentPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads and maps one other-received user-details memes page.
  Future<UserDetailsOtherReceivedMemesListPageEntity>
  listUserDetailsOtherReceivedMemes({
    required String userId,
    required int limit,
    UserDetailsOtherReceivedMemesCursorEntity? cursor,
  }) async {
    try {
      final UserDetailsOtherReceivedMemesListPageDto dto =
          await _userDetailsDatasource.listUserDetailsOtherReceivedMemes(
            userId: userId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _userDetailsMapper.otherReceivedPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Toggles one meme laugh and returns the resulting liked-state.
  Future<bool> toggleUserDetailsMemeLaugh({required String memeId}) async {
    try {
      return await _userDetailsDatasource.toggleUserDetailsMemeLaugh(
        memeId: memeId,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
