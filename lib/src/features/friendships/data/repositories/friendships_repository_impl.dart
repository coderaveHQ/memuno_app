import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/friendships/data/datasources/friendships_datasource.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_requests_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendships_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friendship_mapper.dart';
import 'package:memuno_app/src/features/friendships/data/mappers/friendship_request_mapper.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_entity.dart';
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
  /// Loads one paginated friendships page and maps it to domain entities.
  Future<PaginatedPage<FriendshipEntity, FriendshipCursorEntity>>
  listFriendships({
    String? search,
    required int limit,
    FriendshipCursorEntity? cursor,
  }) async {
    try {
      final FriendshipsPageDto dto = await _friendshipsDatasource
          .listFriendships(
            search: search,
            limit: limit,
            cursorName: cursor?.name,
            cursorId: cursor?.id,
          );

      return PaginatedPage<FriendshipEntity, FriendshipCursorEntity>(
        items: dto.items
            .map(_friendshipMapper.toDomain)
            .toList(growable: false),
        nextCursor: _friendshipCursorFrom(dto),
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads one paginated friendship-requests page and maps to domain entities.
  Future<PaginatedPage<FriendshipRequestEntity, FriendshipRequestCursorEntity>>
  listFriendshipRequests({
    String? search,
    required int limit,
    FriendshipRequestCursorEntity? cursor,
  }) async {
    try {
      final FriendshipRequestsPageDto dto = await _friendshipsDatasource
          .listFriendshipRequests(
            search: search,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );

      return PaginatedPage<
        FriendshipRequestEntity,
        FriendshipRequestCursorEntity
      >(
        items: dto.items
            .map(_friendshipRequestMapper.toDomain)
            .toList(growable: false),
        nextCursor: _friendshipRequestCursorFrom(dto),
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Creates a new friendship request and maps it to a domain entity.
  Future<FriendshipRequestEntity> createFriendshipRequest({
    required String addresseeFriendshipCode,
  }) async {
    try {
      final FriendshipRequestDto dto = await _friendshipsDatasource
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
  Future<FriendshipEntity> acceptFriendshipRequest({
    required String requestId,
  }) async {
    try {
      final FriendshipDto dto = await _friendshipsDatasource
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

  /// Maps friendships page cursor fields into a cursor entity.
  FriendshipCursorEntity? _friendshipCursorFrom(FriendshipsPageDto dto) {
    final String? nextCursorName = dto.nextCursorName;
    final String? nextCursorId = dto.nextCursorId;

    if (nextCursorName == null || nextCursorId == null) {
      return null;
    }

    return FriendshipCursorEntity(name: nextCursorName, id: nextCursorId);
  }

  /// Maps friendship-requests page cursor fields into a cursor entity.
  FriendshipRequestCursorEntity? _friendshipRequestCursorFrom(
    FriendshipRequestsPageDto dto,
  ) {
    final DateTime? nextCursorCreatedAt = dto.nextCursorCreatedAt;
    final String? nextCursorId = dto.nextCursorId;

    if (nextCursorCreatedAt == null || nextCursorId == null) {
      return null;
    }

    return FriendshipRequestCursorEntity(
      createdAt: nextCursorCreatedAt,
      id: nextCursorId,
    );
  }
}
