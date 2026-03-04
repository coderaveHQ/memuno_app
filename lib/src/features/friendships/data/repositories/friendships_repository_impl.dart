import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/friendships/data/datasources/friendships_datasource.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_item_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_item_dto.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friendship_mapper.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friendship_request_mapper.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';

/// Repository implementation for friendship feature operations.
final class FriendshipsRepositoryImpl implements FriendshipsRepository {
  /// Creates the repository.
  const FriendshipsRepositoryImpl({
    required FriendshipsDatasource friendshipsDatasource,
    required FriendshipMapper friendshipMapper,
    required FriendshipRequestMapper friendshipRequestMapper,
    required FailureMapper failureMapper,
  }) : _friendshipsDatasource = friendshipsDatasource,
       _friendshipMapper = friendshipMapper,
       _friendshipRequestMapper = friendshipRequestMapper,
       _failureMapper = failureMapper;

  /// Datasource used for RPC interactions.
  final FriendshipsDatasource _friendshipsDatasource;

  /// Mapper used for friendship DTOs.
  final FriendshipMapper _friendshipMapper;

  /// Mapper used for friendship-request DTOs.
  final FriendshipRequestMapper _friendshipRequestMapper;

  /// Mapper used for converting arbitrary errors into domain failures.
  final FailureMapper _failureMapper;

  @override
  /// Loads one friendship-list page and maps it to domain entities.
  Future<FriendshipListPageEntity> listFriendships({
    String? search,
    required int limit,
    FriendshipCursorEntity? cursor,
  }) async {
    try {
      final FriendshipListPageDto dto = await _friendshipsDatasource
          .listFriendships(
            search: search,
            limit: limit,
            cursorName: cursor?.name,
            cursorId: cursor?.id,
          );
      return _friendshipMapper.pageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads one friendship-request-list page and maps to domain entities.
  Future<FriendshipRequestListPageEntity> listFriendshipRequests({
    String? search,
    required int limit,
    FriendshipRequestCursorEntity? cursor,
  }) async {
    try {
      final FriendshipRequestListPageDto dto = await _friendshipsDatasource
          .listFriendshipRequests(
            search: search,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _friendshipRequestMapper.pageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Creates a new friendship request and maps it to a domain entity.
  Future<FriendshipRequestListPageItemEntity> createFriendshipRequest({
    required String addresseeFriendshipCode,
  }) async {
    try {
      final FriendshipRequestListPageItemDto dto = await _friendshipsDatasource
          .createFriendshipRequest(
            addresseeFriendshipCode: addresseeFriendshipCode,
          );

      return _friendshipRequestMapper.toDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Accepts an incoming request and maps returned friendship entity.
  Future<FriendshipListPageItemEntity> acceptFriendshipRequest({
    required String requestId,
  }) async {
    try {
      final FriendshipListPageItemDto dto = await _friendshipsDatasource
          .acceptFriendshipRequest(requestId: requestId);

      return _friendshipMapper.toDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Declines an incoming friendship request.
  Future<void> declineFriendshipRequest({required String requestId}) async {
    try {
      await _friendshipsDatasource.declineFriendshipRequest(
        requestId: requestId,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Cancels an outgoing friendship request.
  Future<void> cancelFriendshipRequest({required String requestId}) async {
    try {
      await _friendshipsDatasource.cancelFriendshipRequest(
        requestId: requestId,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Deletes an existing friendship.
  Future<void> deleteFriendship({required String friendId}) async {
    try {
      await _friendshipsDatasource.deleteFriendship(friendId: friendId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
