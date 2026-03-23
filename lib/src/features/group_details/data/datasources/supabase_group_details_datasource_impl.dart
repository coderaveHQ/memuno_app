import 'package:memuno_app/src/core/models/items/meme_item_dto.dart';
import 'package:memuno_app/src/core/models/items/user_item_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/features/group_details/data/datasources/group_details_datasource.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_details_dto.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_member_item_dto.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_pending_invitation_item_dto.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [GroupDetailsDatasource].
final class SupabaseGroupDetailsDatasourceImpl
    implements GroupDetailsDatasource {
  const SupabaseGroupDetailsDatasourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  static const String _memesBucket = 'memes';
  static const int _signedUrlExpiresInSeconds = 60 * 60;

  @override
  Future<GroupDetailsDto> getGroupDetails({required String groupId}) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'group_details_get',
      params: <String, dynamic>{'p_group_id': groupId},
    );

    return GroupDetailsDto.fromJson(
      _asObjectMap(payload, rpcName: 'group_details_get'),
    );
  }

  @override
  Future<ListPageDto<MemeItemDto>> listGroupDetailsMemesAll({
    required String groupId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final ListPageDto<MemeItemDto> page = await _listMemeItemPage(
      rpcName: 'group_details_memes_all_list',
      params: <String, dynamic>{
        'p_group_id': groupId,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );
    return _attachSignedUrlsToMemeItemPage(page);
  }

  @override
  Future<ListPageDto<MemeItemDto>> listGroupDetailsMemesSentByMe({
    required String groupId,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final ListPageDto<MemeItemDto> page = await _listMemeItemPage(
      rpcName: 'group_details_memes_sent_by_me_list',
      params: <String, dynamic>{
        'p_group_id': groupId,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );
    return _attachSignedUrlsToMemeItemPage(page);
  }

  @override
  Future<ListPageDto<GroupMemberItemDto>> listGroupDetailsMembers({
    required String groupId,
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'group_details_members_list',
      params: <String, dynamic>{
        'p_group_id': groupId,
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    return ListPageDto<GroupMemberItemDto>.fromJson(
      _asObjectMap(payload, rpcName: 'group_details_members_list'),
      itemFromJson: GroupMemberItemDto.fromJson,
    );
  }

  @override
  Future<ListPageDto<GroupPendingInvitationItemDto>>
  listGroupDetailsPendingInvitations({
    required String groupId,
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'group_details_pending_invitations_list',
      params: <String, dynamic>{
        'p_group_id': groupId,
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    return ListPageDto<GroupPendingInvitationItemDto>.fromJson(
      _asObjectMap(payload, rpcName: 'group_details_pending_invitations_list'),
      itemFromJson: GroupPendingInvitationItemDto.fromJson,
    );
  }

  @override
  Future<ListPageDto<UserItemDto>> listGroupInvitableFriends({
    required String groupId,
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'group_invitable_friends_list',
      params: <String, dynamic>{
        'p_group_id': groupId,
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    return ListPageDto<UserItemDto>.fromJson(
      _asObjectMap(payload, rpcName: 'group_invitable_friends_list'),
      itemFromJson: UserItemDto.fromJson,
    );
  }

  @override
  Future<void> inviteGroupMembers({
    required String groupId,
    required List<String> inviteeUserIds,
  }) {
    return _supabaseClient.rpc<void>(
      'group_members_invite',
      params: <String, dynamic>{
        'p_group_id': groupId,
        'p_invitee_ids': inviteeUserIds,
      },
    );
  }

  @override
  Future<void> updateGroupMemberRole({
    required String groupId,
    required String userId,
    required GroupUserType type,
  }) {
    return _supabaseClient.rpc<void>(
      'group_member_role_update',
      params: <String, dynamic>{
        'p_group_id': groupId,
        'p_user_id': userId,
        'p_type': type.databaseValue,
      },
    );
  }

  @override
  Future<void> removeGroupMember({
    required String groupId,
    required String userId,
  }) {
    return _supabaseClient.rpc<void>(
      'group_member_remove',
      params: <String, dynamic>{'p_group_id': groupId, 'p_user_id': userId},
    );
  }

  @override
  Future<void> updateGroupName({
    required String groupId,
    required String name,
  }) {
    return _supabaseClient.rpc<void>(
      'group_name_update',
      params: <String, dynamic>{'p_group_id': groupId, 'p_name': name},
    );
  }

  @override
  Future<void> deleteGroup({required String groupId}) {
    return _supabaseClient.rpc<void>(
      'group_delete',
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

  Future<ListPageDto<MemeItemDto>> _listMemeItemPage({
    required String rpcName,
    required Map<String, dynamic> params,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      rpcName,
      params: params,
    );

    return ListPageDto<MemeItemDto>.fromJson(
      _asObjectMap(payload, rpcName: rpcName),
      itemFromJson: MemeItemDto.fromJson,
    );
  }

  Future<ListPageDto<MemeItemDto>> _attachSignedUrlsToMemeItemPage(
    ListPageDto<MemeItemDto> page,
  ) async {
    final Map<String, String> signedUrlByPath = await _createSignedUrlMap(
      page.items
          .map((MemeItemDto item) => item.imagePath)
          .toSet()
          .toList(growable: false),
    );

    final List<MemeItemDto> signedItems = page.items
        .map((MemeItemDto item) {
          return item.copyWith(signedImageUrl: signedUrlByPath[item.imagePath]);
        })
        .toList(growable: false);

    return ListPageDto<MemeItemDto>(
      items: signedItems,
      nextCursorCreatedAt: page.nextCursorCreatedAt,
      nextCursorId: page.nextCursorId,
    );
  }

  Future<Map<String, String>> _createSignedUrlMap(List<String> paths) async {
    if (paths.isEmpty) {
      return const <String, String>{};
    }

    final List<dynamic> signedUrls = await _supabaseClient.storage
        .from(_memesBucket)
        .createSignedUrls(paths, _signedUrlExpiresInSeconds);

    final Map<String, String> signedUrlByPath = <String, String>{};
    for (final dynamic signedUrl in signedUrls) {
      final Object? path = signedUrl.path;
      final Object? url = signedUrl.signedUrl;
      if (path is String &&
          path.isNotEmpty &&
          url is String &&
          url.isNotEmpty) {
        signedUrlByPath[path] = url;
      }
    }

    return signedUrlByPath;
  }
}
