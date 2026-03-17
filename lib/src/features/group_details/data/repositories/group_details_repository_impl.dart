import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/models/items/meme_item_dto.dart';
import 'package:memuno_app/src/core/models/items/meme_item_entity.dart';
import 'package:memuno_app/src/core/models/items/user_item_dto.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/group_details/data/datasources/group_details_datasource.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_details_dto.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_member_item_dto.dart';
import 'package:memuno_app/src/features/group_details/data/dto/group_pending_invitation_item_dto.dart';
import 'package:memuno_app/src/features/group_details/data/mappers/group_details_mapper.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_details_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_member_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_pending_invitation_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Repository implementation for group-details operations.
final class GroupDetailsRepositoryImpl implements GroupDetailsRepository {
  const GroupDetailsRepositoryImpl({
    required GroupDetailsDatasource groupDetailsDatasource,
    required GroupDetailsMapper groupDetailsMapper,
    required FailureMapper failureMapper,
  }) : _groupDetailsDatasource = groupDetailsDatasource,
       _groupDetailsMapper = groupDetailsMapper,
       _failureMapper = failureMapper;

  final GroupDetailsDatasource _groupDetailsDatasource;
  final GroupDetailsMapper _groupDetailsMapper;
  final FailureMapper _failureMapper;

  @override
  Future<GroupDetailsEntity> getGroupDetails({required String groupId}) async {
    try {
      final GroupDetailsDto dto = await _groupDetailsDatasource.getGroupDetails(
        groupId: groupId,
      );
      return _groupDetailsMapper.detailsToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<ListPageEntity<MemeItemEntity>> listGroupDetailsMemesAll({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<MemeItemDto> dto = await _groupDetailsDatasource
          .listGroupDetailsMemesAll(
            groupId: groupId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _groupDetailsMapper.memePageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<ListPageEntity<MemeItemEntity>> listGroupDetailsMemesSentByMe({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<MemeItemDto> dto = await _groupDetailsDatasource
          .listGroupDetailsMemesSentByMe(
            groupId: groupId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _groupDetailsMapper.memePageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<ListPageEntity<GroupMemberItemEntity>> listGroupDetailsMembers({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<GroupMemberItemDto> dto = await _groupDetailsDatasource
          .listGroupDetailsMembers(
            groupId: groupId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _groupDetailsMapper.membersPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<ListPageEntity<GroupPendingInvitationItemEntity>>
  listGroupDetailsPendingInvitations({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<GroupPendingInvitationItemDto> dto =
          await _groupDetailsDatasource.listGroupDetailsPendingInvitations(
            groupId: groupId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _groupDetailsMapper.pendingInvitationsPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<ListPageEntity<UserItemEntity>> listGroupInvitableFriends({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<UserItemDto> dto = await _groupDetailsDatasource
          .listGroupInvitableFriends(
            groupId: groupId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _groupDetailsMapper.usersPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> inviteGroupMembers({
    required String groupId,
    required List<String> inviteeUserIds,
  }) async {
    try {
      await _groupDetailsDatasource.inviteGroupMembers(
        groupId: groupId,
        inviteeUserIds: inviteeUserIds,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> updateGroupMemberRole({
    required String groupId,
    required String userId,
    required GroupUserType type,
  }) async {
    try {
      await _groupDetailsDatasource.updateGroupMemberRole(
        groupId: groupId,
        userId: userId,
        type: type,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> removeGroupMember({
    required String groupId,
    required String userId,
  }) async {
    try {
      await _groupDetailsDatasource.removeGroupMember(
        groupId: groupId,
        userId: userId,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> updateGroupName({
    required String groupId,
    required String name,
  }) async {
    try {
      await _groupDetailsDatasource.updateGroupName(
        groupId: groupId,
        name: name,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> deleteGroup({required String groupId}) async {
    try {
      await _groupDetailsDatasource.deleteGroup(groupId: groupId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
