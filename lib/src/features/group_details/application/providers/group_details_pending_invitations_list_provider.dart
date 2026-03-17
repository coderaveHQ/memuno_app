import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/group_details/application/providers/usecases/list_group_details_pending_invitations_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/entities/group_pending_invitation_item_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/list_group_details_pending_invitations_usecase.dart';
import 'package:memuno_app/src/features/groups/application/providers/usecases/cancel_group_invitation_usecase_provider.dart';
import 'package:memuno_app/src/features/groups/domain/usecases/cancel_group_invitation_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_pending_invitations_list_provider.g.dart';

/// Async paginated controller for pending invitations in group-details info.
@Riverpod(keepAlive: true)
class GroupDetailsPendingInvitationsList
    extends _$GroupDetailsPendingInvitationsList
    with
        AsyncPaginationMixin<
          GroupPendingInvitationItemEntity,
          ListCursorEntity
        >,
        OptimisticAsyncStateMixin<
          PaginatedListState<GroupPendingInvitationItemEntity, ListCursorEntity>
        > {
  @override
  Future<PaginatedListState<GroupPendingInvitationItemEntity, ListCursorEntity>>
  build(String groupId) {
    return buildPaginatedState();
  }

  @override
  Future<PaginatedPage<GroupPendingInvitationItemEntity, ListCursorEntity>>
  loadPage({required int limit, ListCursorEntity? cursor}) async {
    final ListGroupDetailsPendingInvitationsUsecase usecase = ref.watch(
      listGroupDetailsPendingInvitationsUsecaseProvider,
    );
    final ListPageEntity<GroupPendingInvitationItemEntity> page = await usecase(
      groupId: groupId,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<GroupPendingInvitationItemEntity, ListCursorEntity>(
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

  /// Cancels one invitation with optimistic rollback support.
  Future<void> cancelInvitation(
    GroupPendingInvitationItemEntity invitation,
  ) async {
    final PaginatedListState<
      GroupPendingInvitationItemEntity,
      ListCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final int originalIndex = current.items.indexWhere(
      (GroupPendingInvitationItemEntity item) => item.id == invitation.id,
    );
    if (originalIndex < 0) {
      return;
    }

    await runOptimisticUpdate<void>(
      apply:
          (
            PaginatedListState<
              GroupPendingInvitationItemEntity,
              ListCursorEntity
            >
            state,
          ) {
            return _removeInvitationFromState(
              state,
              invitationId: invitation.id,
            );
          },
      rollback:
          (
            PaginatedListState<
              GroupPendingInvitationItemEntity,
              ListCursorEntity
            >
            state,
          ) {
            return _restoreInvitationInState(
              state: state,
              invitation: invitation,
              originalIndex: originalIndex,
            );
          },
      operation: () async {
        final CancelGroupInvitationUsecase usecase = ref.read(
          cancelGroupInvitationUsecaseProvider,
        );
        await usecase(invitationId: invitation.id);
      },
    );
  }

  PaginatedListState<GroupPendingInvitationItemEntity, ListCursorEntity>
  _removeInvitationFromState(
    PaginatedListState<GroupPendingInvitationItemEntity, ListCursorEntity>
    state, {
    required String invitationId,
  }) {
    final List<GroupPendingInvitationItemEntity> nextItems = state.items
        .where(
          (GroupPendingInvitationItemEntity item) => item.id != invitationId,
        )
        .toList(growable: false);

    return state.copyWith(
      items: List<GroupPendingInvitationItemEntity>.unmodifiable(nextItems),
    );
  }

  PaginatedListState<GroupPendingInvitationItemEntity, ListCursorEntity>
  _restoreInvitationInState({
    required PaginatedListState<
      GroupPendingInvitationItemEntity,
      ListCursorEntity
    >
    state,
    required GroupPendingInvitationItemEntity invitation,
    required int originalIndex,
  }) {
    final bool alreadyPresent = state.items.any(
      (GroupPendingInvitationItemEntity item) => item.id == invitation.id,
    );
    if (alreadyPresent) {
      return state;
    }

    final List<GroupPendingInvitationItemEntity> nextItems =
        List<GroupPendingInvitationItemEntity>.of(state.items, growable: true);
    final int safeIndex = originalIndex.clamp(0, nextItems.length);
    nextItems.insert(safeIndex, invitation);

    return state.copyWith(
      items: List<GroupPendingInvitationItemEntity>.unmodifiable(nextItems),
    );
  }

  ListCursorEntity? _cursorFromPage(
    ListPageEntity<GroupPendingInvitationItemEntity> page,
  ) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return ListCursorEntity(createdAt: createdAt, id: id);
  }
}
