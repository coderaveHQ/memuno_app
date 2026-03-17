import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/groups/data/datasources/groups_datasource.dart';
import 'package:memuno_app/src/features/groups/data/dto/group_invitation_item_dto.dart';
import 'package:memuno_app/src/features/groups/data/dto/group_item_dto.dart';
import 'package:memuno_app/src/features/groups/data/mappers/group_invitation_mapper.dart';
import 'package:memuno_app/src/features/groups/data/mappers/group_mapper.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/repositories/groups_repository.dart';

/// Repository implementation for groups feature operations.
final class GroupsRepositoryImpl implements GroupsRepository {
  const GroupsRepositoryImpl({
    required GroupsDatasource groupsDatasource,
    required GroupMapper groupMapper,
    required GroupInvitationMapper groupInvitationMapper,
    required FailureMapper failureMapper,
  }) : _groupsDatasource = groupsDatasource,
       _groupMapper = groupMapper,
       _groupInvitationMapper = groupInvitationMapper,
       _failureMapper = failureMapper;

  final GroupsDatasource _groupsDatasource;
  final GroupMapper _groupMapper;
  final GroupInvitationMapper _groupInvitationMapper;
  final FailureMapper _failureMapper;

  @override
  Future<ListPageEntity<GroupItemEntity>> listGroups({
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<GroupItemDto> dto = await _groupsDatasource.listGroups(
        search: search,
        limit: limit,
        cursorCreatedAt: cursor?.createdAt,
        cursorId: cursor?.id,
      );
      return _groupMapper.pageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<ListPageEntity<GroupInvitationItemEntity>> listGroupInvitations({
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<GroupInvitationItemDto> dto = await _groupsDatasource
          .listGroupInvitations(
            search: search,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _groupInvitationMapper.pageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<GroupItemEntity> createGroup({
    required String name,
    required List<String> inviteeUserIds,
  }) async {
    try {
      final GroupItemDto dto = await _groupsDatasource.createGroup(
        name: name,
        inviteeUserIds: inviteeUserIds,
      );
      return _groupMapper.toDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<GroupItemEntity> acceptGroupInvitation({
    required String invitationId,
  }) async {
    try {
      final GroupItemDto dto = await _groupsDatasource.acceptGroupInvitation(
        invitationId: invitationId,
      );
      return _groupMapper.toDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> rejectGroupInvitation({required String invitationId}) async {
    try {
      await _groupsDatasource.rejectGroupInvitation(invitationId: invitationId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> cancelGroupInvitation({required String invitationId}) async {
    try {
      await _groupsDatasource.cancelGroupInvitation(invitationId: invitationId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> leaveGroup({required String groupId}) async {
    try {
      await _groupsDatasource.leaveGroup(groupId: groupId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
