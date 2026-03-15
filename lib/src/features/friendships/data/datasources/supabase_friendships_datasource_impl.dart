import 'package:memuno_app/src/features/friendships/data/datasources/friendships_datasource.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_list_page_item_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_dto.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_list_page_item_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [FriendshipsDatasource].
final class SupabaseFriendshipsDatasourceImpl implements FriendshipsDatasource {
  /// Creates the datasource.
  const SupabaseFriendshipsDatasourceImpl({
    /// Supabase client used for RPC execution.
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  /// Supabase client used for all friendship calls.
  final SupabaseClient _supabaseClient;

  @override
  /// Loads one page from `friendships_list` RPC.
  Future<FriendshipListPageDto> listFriendships({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'friendships_list',
      params: <String, dynamic>{
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'friendships_list',
    );

    return FriendshipListPageDto.fromJson(json);
  }

  @override
  /// Loads one page from `friendship_requests_list` RPC.
  Future<FriendshipRequestListPageDto> listFriendshipRequests({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'friendship_requests_list',
      params: <String, dynamic>{
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'friendship_requests_list',
    );

    return FriendshipRequestListPageDto.fromJson(json);
  }

  @override
  /// Calls `friendship_request_create` and maps its item payload.
  Future<FriendshipRequestListPageItemDto> createFriendshipRequest({
    required String addresseeFriendshipCode,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'friendship_request_create',
      params: <String, dynamic>{
        'p_addressee_friendship_code': addresseeFriendshipCode,
      },
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'friendship_request_create',
    );

    return FriendshipRequestListPageItemDto.fromJson(json);
  }

  @override
  /// Calls `friendship_request_accept` and maps the created friendship payload.
  Future<FriendshipListPageItemDto> acceptFriendshipRequest({
    required String requestId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'friendship_request_accept',
      params: <String, dynamic>{'p_request_id': requestId},
    );

    final Map<String, Object?> json = _asObjectMap(
      payload,
      rpcName: 'friendship_request_accept',
    );

    return FriendshipListPageItemDto.fromJson(json);
  }

  @override
  /// Calls `friendship_request_decline` for an incoming request.
  Future<void> declineFriendshipRequest({required String requestId}) async {
    await _supabaseClient.rpc<void>(
      'friendship_request_decline',
      params: <String, dynamic>{'p_request_id': requestId},
    );
  }

  @override
  /// Calls `friendship_request_cancel` for an outgoing request.
  Future<void> cancelFriendshipRequest({required String requestId}) async {
    await _supabaseClient.rpc<void>(
      'friendship_request_cancel',
      params: <String, dynamic>{'p_request_id': requestId},
    );
  }

  @override
  /// Calls `friendship_delete` to unfriend a user.
  Future<void> deleteFriendship({required String friendId}) async {
    await _supabaseClient.rpc<void>(
      'friendship_delete',
      params: <String, dynamic>{'p_friend_id': friendId},
    );
  }

  /// Casts an RPC payload to `Map<String, Object?>`.
  Map<String, Object?> _asObjectMap(
    Object? payload, {
    required String rpcName,
  }) {
    if (payload is! Map) {
      throw FormatException(
        'Expected `$rpcName` to return a JSON object payload.',
      );
    }

    return Map<String, Object?>.from(payload);
  }
}
