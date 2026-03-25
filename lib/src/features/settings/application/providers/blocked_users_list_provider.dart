import 'package:memuno_app/src/core/models/items/user_item_dto.dart';
import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/infrastructure/supabase/supabase_client_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'blocked_users_list_provider.g.dart';

/// Async paginated controller for users blocked by the current user.
@Riverpod(keepAlive: true)
class BlockedUsersList extends _$BlockedUsersList
    with
        AsyncPaginationMixin<UserItemEntity, ListCursorEntity>,
        AsyncPaginationSearchMixin<UserItemEntity, ListCursorEntity>,
        OptimisticAsyncStateMixin<
          PaginatedListState<UserItemEntity, ListCursorEntity>
        > {
  @override
  Future<PaginatedListState<UserItemEntity, ListCursorEntity>> build() {
    return buildSearchPaginatedState();
  }

  @override
  Future<PaginatedPage<UserItemEntity, ListCursorEntity>> loadPage({
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    final SupabaseClient supabaseClient = ref.watch(supabaseClientProvider);

    final Object? payload = await supabaseClient.rpc<Object?>(
      'user_blocked_users_list',
      params: <String, dynamic>{
        'p_search': searchQuery,
        'p_limit': limit,
        'p_cursor_created_at': cursor?.createdAt.toIso8601String(),
        'p_cursor_id': cursor?.id,
      },
    );

    final ListPageDto<UserItemDto> page = ListPageDto<UserItemDto>.fromJson(
      _asObjectMap(payload, rpcName: 'user_blocked_users_list'),
      itemFromJson: UserItemDto.fromJson,
    );

    return PaginatedPage<UserItemEntity, ListCursorEntity>(
      items: page.items.map(_toUserItemEntity).toList(growable: false),
      nextCursor: _cursorFromPage(page),
    );
  }

  /// Refreshes the blocked users list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next blocked users page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Unblocks one user with optimistic removal and rollback support.
  Future<void> unblockUser(UserItemEntity user) async {
    final PaginatedListState<UserItemEntity, ListCursorEntity>? current =
        state.asData?.value;
    if (current == null) {
      return;
    }

    final int originalIndex = current.items.indexWhere(
      (UserItemEntity item) => item.id == user.id,
    );
    if (originalIndex < 0) {
      return;
    }

    await runOptimisticUpdate<void>(
      apply: (PaginatedListState<UserItemEntity, ListCursorEntity> state) {
        return _removeUserFromState(state, userId: user.id);
      },
      rollback: (PaginatedListState<UserItemEntity, ListCursorEntity> state) {
        return _restoreUserInState(
          state: state,
          user: user,
          originalIndex: originalIndex,
        );
      },
      operation: () async {
        final SupabaseClient supabaseClient = ref.read(supabaseClientProvider);
        await supabaseClient.rpc<void>(
          'user_unblock',
          params: <String, dynamic>{'p_target_user_id': user.id},
        );
      },
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

  UserItemEntity _toUserItemEntity(UserItemDto dto) {
    return UserItemEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  ListCursorEntity? _cursorFromPage(ListPageDto<UserItemDto> page) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return ListCursorEntity(createdAt: createdAt, id: id);
  }

  PaginatedListState<UserItemEntity, ListCursorEntity> _removeUserFromState(
    PaginatedListState<UserItemEntity, ListCursorEntity> state, {
    required String userId,
  }) {
    final List<UserItemEntity> nextItems = state.items
        .where((UserItemEntity item) => item.id != userId)
        .toList(growable: false);

    return state.copyWith(items: List<UserItemEntity>.unmodifiable(nextItems));
  }

  PaginatedListState<UserItemEntity, ListCursorEntity> _restoreUserInState({
    required PaginatedListState<UserItemEntity, ListCursorEntity> state,
    required UserItemEntity user,
    required int originalIndex,
  }) {
    final bool alreadyPresent = state.items.any(
      (UserItemEntity item) => item.id == user.id,
    );
    if (alreadyPresent) {
      return state;
    }

    final List<UserItemEntity> nextItems = List<UserItemEntity>.of(
      state.items,
      growable: true,
    );
    final int safeIndex = originalIndex.clamp(0, nextItems.length);
    nextItems.insert(safeIndex, user);

    return state.copyWith(items: List<UserItemEntity>.unmodifiable(nextItems));
  }
}
