import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/groups/application/providers/groups_list_provider.dart';
import 'package:memuno_app/src/features/groups/application/providers/usecases/accept_group_invitation_usecase_provider.dart';
import 'package:memuno_app/src/features/groups/application/providers/usecases/list_group_invitations_usecase_provider.dart';
import 'package:memuno_app/src/features/groups/application/providers/usecases/reject_group_invitation_usecase_provider.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_invitation_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/entities/group_item_entity.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/accept_group_invitation_usecase.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/list_group_invitations_usecase.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/reject_group_invitation_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_invitations_list_provider.g.dart';

/// Async paginated controller for incoming group invitations.
@Riverpod(keepAlive: true)
class GroupInvitationsList extends _$GroupInvitationsList
    with
        AsyncPaginationMixin<GroupInvitationItemEntity, ListCursorEntity>,
        AsyncPaginationSearchMixin<GroupInvitationItemEntity, ListCursorEntity>,
        OptimisticAsyncStateMixin<
          PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>
        > {
  @override
  Future<PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>>
  build() {
    return buildSearchPaginatedState();
  }

  @override
  Future<PaginatedPage<GroupInvitationItemEntity, ListCursorEntity>> loadPage({
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    final ListGroupInvitationsUsecase usecase = ref.watch(
      listGroupInvitationsUsecaseProvider,
    );
    final ListPageEntity<GroupInvitationItemEntity> page = await usecase(
      search: searchQuery,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<GroupInvitationItemEntity, ListCursorEntity>(
      items: page.items,
      nextCursor: _cursorFromPage(page),
    );
  }

  /// Refreshes the invitations list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next invitations page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Accepts one invitation with optimistic removal and rollback.
  Future<GroupItemEntity> acceptInvitation(
    GroupInvitationItemEntity invitation,
  ) async {
    final PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>?
    current = state.asData?.value;
    if (current == null) {
      throw StateError('Group invitations must be loaded before accepting.');
    }

    final int originalIndex = _indexOfInvitation(current.items, invitation);
    if (originalIndex < 0) {
      throw StateError(
        'Cannot accept invitation that is not currently listed.',
      );
    }

    return runOptimisticUpdate<GroupItemEntity>(
      apply:
          (
            PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>
            state,
          ) {
            return _removeInvitationFromState(
              state,
              invitationId: invitation.id,
            );
          },
      rollback:
          (
            PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>
            state,
          ) {
            return _restoreInvitationInState(
              state: state,
              invitation: invitation,
              originalIndex: originalIndex,
            );
          },
      operation: () async {
        final AcceptGroupInvitationUsecase usecase = ref.read(
          acceptGroupInvitationUsecaseProvider,
        );
        final GroupItemEntity group = await usecase(
          invitationId: invitation.id,
        );

        ref.read(groupsListProvider.notifier).upsertGroup(group);
        return group;
      },
    );
  }

  /// Rejects one invitation with optimistic removal and rollback.
  Future<void> rejectInvitation(GroupInvitationItemEntity invitation) async {
    final PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>?
    current = state.asData?.value;
    if (current == null) {
      throw StateError('Group invitations must be loaded before rejecting.');
    }

    final int originalIndex = _indexOfInvitation(current.items, invitation);
    if (originalIndex < 0) {
      return;
    }

    await runOptimisticUpdate<void>(
      apply:
          (
            PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>
            state,
          ) {
            return _removeInvitationFromState(
              state,
              invitationId: invitation.id,
            );
          },
      rollback:
          (
            PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>
            state,
          ) {
            return _restoreInvitationInState(
              state: state,
              invitation: invitation,
              originalIndex: originalIndex,
            );
          },
      operation: () async {
        final RejectGroupInvitationUsecase usecase = ref.read(
          rejectGroupInvitationUsecaseProvider,
        );
        await usecase(invitationId: invitation.id);
      },
    );
  }

  int _indexOfInvitation(
    List<GroupInvitationItemEntity> items,
    GroupInvitationItemEntity invitation,
  ) {
    return items.indexWhere(
      (GroupInvitationItemEntity item) => item.id == invitation.id,
    );
  }

  PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>
  _removeInvitationFromState(
    PaginatedListState<GroupInvitationItemEntity, ListCursorEntity> state, {
    required String invitationId,
  }) {
    final List<GroupInvitationItemEntity> nextItems = state.items
        .where((GroupInvitationItemEntity item) => item.id != invitationId)
        .toList(growable: false);

    return state.copyWith(
      items: List<GroupInvitationItemEntity>.unmodifiable(nextItems),
    );
  }

  PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>
  _restoreInvitationInState({
    required PaginatedListState<GroupInvitationItemEntity, ListCursorEntity>
    state,
    required GroupInvitationItemEntity invitation,
    required int originalIndex,
  }) {
    final bool alreadyPresent = state.items.any(
      (GroupInvitationItemEntity item) => item.id == invitation.id,
    );
    if (alreadyPresent) {
      return state;
    }

    final List<GroupInvitationItemEntity> nextItems =
        List<GroupInvitationItemEntity>.of(state.items, growable: true);
    final int safeIndex = originalIndex.clamp(0, nextItems.length);
    nextItems.insert(safeIndex, invitation);

    return state.copyWith(
      items: List<GroupInvitationItemEntity>.unmodifiable(nextItems),
    );
  }

  ListCursorEntity? _cursorFromPage(
    ListPageEntity<GroupInvitationItemEntity> page,
  ) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return ListCursorEntity(createdAt: createdAt, id: id);
  }
}
