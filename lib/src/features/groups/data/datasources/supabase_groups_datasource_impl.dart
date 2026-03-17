import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/features/groups/data/datasources/groups_datasource.dart';
import 'package:memuno_app/src/features/groups/data/dto/group_invitation_item_dto.dart';
import 'package:memuno_app/src/features/groups/data/dto/group_item_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [GroupsDatasource].
final class SupabaseGroupsDatasourceImpl implements GroupsDatasource {
  const SupabaseGroupsDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<ListPageDto<GroupItemDto>> listGroups({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'groups_list',
      params: <String, dynamic>{
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    return ListPageDto<GroupItemDto>.fromJson(
      _asObjectMap(payload, rpcName: 'groups_list'),
      itemFromJson: GroupItemDto.fromJson,
    );
  }

  @override
  Future<ListPageDto<GroupInvitationItemDto>> listGroupInvitations({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'group_invitations_list',
      params: <String, dynamic>{
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    return ListPageDto<GroupInvitationItemDto>.fromJson(
      _asObjectMap(payload, rpcName: 'group_invitations_list'),
      itemFromJson: GroupInvitationItemDto.fromJson,
    );
  }

  @override
  Future<GroupItemDto> createGroup({
    required String name,
    required List<String> inviteeUserIds,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'group_create',
      params: <String, dynamic>{
        'p_name': name,
        'p_invitee_ids': inviteeUserIds,
      },
    );

    return GroupItemDto.fromJson(
      _asObjectMap(payload, rpcName: 'group_create'),
    );
  }

  @override
  Future<GroupItemDto> acceptGroupInvitation({
    required String invitationId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'group_invitation_accept',
      params: <String, dynamic>{'p_invitation_id': invitationId},
    );

    return GroupItemDto.fromJson(
      _asObjectMap(payload, rpcName: 'group_invitation_accept'),
    );
  }

  @override
  Future<void> rejectGroupInvitation({required String invitationId}) {
    return _supabaseClient.rpc<void>(
      'group_invitation_reject',
      params: <String, dynamic>{'p_invitation_id': invitationId},
    );
  }

  @override
  Future<void> cancelGroupInvitation({required String invitationId}) {
    return _supabaseClient.rpc<void>(
      'group_invitation_cancel',
      params: <String, dynamic>{'p_invitation_id': invitationId},
    );
  }

  @override
  Future<void> leaveGroup({required String groupId}) {
    return _supabaseClient.rpc<void>(
      'group_leave',
      params: <String, dynamic>{'p_group_id': groupId},
    );
  }

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
