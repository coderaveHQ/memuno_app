import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/group_details/application/providers/usecases/list_group_details_members_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/usecases/remove_group_member_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/application/providers/usecases/update_group_member_role_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_member_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_user_type.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/list_group_details_members_usecase.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/remove_group_member_usecase.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/update_group_member_role_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_members_list_provider.g.dart';

/// Async paginated controller for group members.
@Riverpod(keepAlive: true)
class GroupDetailsMembersList extends _$GroupDetailsMembersList
    with
        AsyncPaginationMixin<GroupMemberItemEntity, ListCursorEntity>,
        AsyncPaginationSearchMixin<GroupMemberItemEntity, ListCursorEntity>,
        OptimisticAsyncStateMixin<
          PaginatedListState<GroupMemberItemEntity, ListCursorEntity>
        > {
  @override
  Future<PaginatedListState<GroupMemberItemEntity, ListCursorEntity>> build(
    String groupId,
  ) {
    return buildSearchPaginatedState();
  }

  @override
  Future<PaginatedPage<GroupMemberItemEntity, ListCursorEntity>> loadPage({
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    final ListGroupDetailsMembersUsecase usecase = ref.watch(
      listGroupDetailsMembersUsecaseProvider,
    );
    final ListPageEntity<GroupMemberItemEntity> page = await usecase(
      groupId: groupId,
      search: searchQuery,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<GroupMemberItemEntity, ListCursorEntity>(
      items: page.items,
      nextCursor: _cursorFromPage(page),
    );
  }

  /// Refreshes the list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next list page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Removes one member with optimistic rollback support.
  Future<void> removeMember(GroupMemberItemEntity member) async {
    final PaginatedListState<GroupMemberItemEntity, ListCursorEntity>? current =
        state.asData?.value;
    if (current == null) {
      return;
    }

    final int originalIndex = current.items.indexWhere(
      (GroupMemberItemEntity item) => item.user.id == member.user.id,
    );
    if (originalIndex < 0) {
      return;
    }

    await runOptimisticUpdate<void>(
      apply:
          (PaginatedListState<GroupMemberItemEntity, ListCursorEntity> state) {
            return _removeMemberFromState(state, userId: member.user.id);
          },
      rollback:
          (PaginatedListState<GroupMemberItemEntity, ListCursorEntity> state) {
            return _restoreMemberInState(
              state: state,
              member: member,
              originalIndex: originalIndex,
            );
          },
      operation: () async {
        final RemoveGroupMemberUsecase usecase = ref.read(
          removeGroupMemberUsecaseProvider,
        );
        await usecase(groupId: groupId, userId: member.user.id);
      },
    );
  }

  /// Updates one member role with optimistic rollback support.
  Future<void> updateMemberRole({
    required GroupMemberItemEntity member,
    required GroupUserType nextType,
  }) async {
    if (member.type == nextType) {
      return;
    }

    final PaginatedListState<GroupMemberItemEntity, ListCursorEntity>? current =
        state.asData?.value;
    if (current == null) {
      return;
    }

    final int originalIndex = current.items.indexWhere(
      (GroupMemberItemEntity item) => item.user.id == member.user.id,
    );
    if (originalIndex < 0) {
      return;
    }

    await runOptimisticUpdate<void>(
      apply:
          (PaginatedListState<GroupMemberItemEntity, ListCursorEntity> state) {
            return _updateMemberRoleInState(
              state: state,
              userId: member.user.id,
              nextType: nextType,
            );
          },
      rollback:
          (PaginatedListState<GroupMemberItemEntity, ListCursorEntity> state) {
            return _updateMemberRoleInState(
              state: state,
              userId: member.user.id,
              nextType: member.type,
            );
          },
      operation: () async {
        final UpdateGroupMemberRoleUsecase usecase = ref.read(
          updateGroupMemberRoleUsecaseProvider,
        );
        await usecase(groupId: groupId, userId: member.user.id, type: nextType);
      },
    );
  }

  PaginatedListState<GroupMemberItemEntity, ListCursorEntity>
  _removeMemberFromState(
    PaginatedListState<GroupMemberItemEntity, ListCursorEntity> state, {
    required String userId,
  }) {
    final List<GroupMemberItemEntity> nextItems = state.items
        .where((GroupMemberItemEntity item) => item.user.id != userId)
        .toList(growable: false);

    return state.copyWith(
      items: List<GroupMemberItemEntity>.unmodifiable(nextItems),
    );
  }

  PaginatedListState<GroupMemberItemEntity, ListCursorEntity>
  _restoreMemberInState({
    required PaginatedListState<GroupMemberItemEntity, ListCursorEntity> state,
    required GroupMemberItemEntity member,
    required int originalIndex,
  }) {
    final bool alreadyPresent = state.items.any(
      (GroupMemberItemEntity item) => item.user.id == member.user.id,
    );
    if (alreadyPresent) {
      return state;
    }

    final List<GroupMemberItemEntity> nextItems =
        List<GroupMemberItemEntity>.of(state.items, growable: true);
    final int safeIndex = originalIndex.clamp(0, nextItems.length);
    nextItems.insert(safeIndex, member);

    return state.copyWith(
      items: List<GroupMemberItemEntity>.unmodifiable(nextItems),
    );
  }

  PaginatedListState<GroupMemberItemEntity, ListCursorEntity>
  _updateMemberRoleInState({
    required PaginatedListState<GroupMemberItemEntity, ListCursorEntity> state,
    required String userId,
    required GroupUserType nextType,
  }) {
    final List<GroupMemberItemEntity> nextItems = state.items
        .map((GroupMemberItemEntity item) {
          if (item.user.id != userId) {
            return item;
          }
          return item.copyWith(type: nextType);
        })
        .toList(growable: false);

    return state.copyWith(
      items: List<GroupMemberItemEntity>.unmodifiable(nextItems),
    );
  }

  ListCursorEntity? _cursorFromPage(
    ListPageEntity<GroupMemberItemEntity> page,
  ) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return ListCursorEntity(createdAt: createdAt, id: id);
  }
}
