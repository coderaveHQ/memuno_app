import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/core/state/search/async_pagination_search_mixin.dart';
import 'package:memuno_app/src/features/friendships/application/providers/friendships_list_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/accept_friendship_request_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/cancel_friendship_request_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/create_friendship_request_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/decline_friendship_request_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/application/providers/usecases/list_friendship_requests_usecase_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_direction.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_list_page_item_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/accept_friendship_request_usecase.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/cancel_friendship_request_usecase.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/create_friendship_request_usecase.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/decline_friendship_request_usecase.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/list_friendship_requests_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'friendship_requests_list_provider.g.dart';

/// Async paginated controller for pending friendship requests.
@Riverpod(keepAlive: true)
class FriendshipRequestsList extends _$FriendshipRequestsList
    with
        AsyncPaginationMixin<
          FriendshipRequestListPageItemEntity,
          FriendshipRequestCursorEntity
        >,
        AsyncPaginationSearchMixin<
          FriendshipRequestListPageItemEntity,
          FriendshipRequestCursorEntity
        >,
        OptimisticAsyncStateMixin<
          PaginatedListState<
            FriendshipRequestListPageItemEntity,
            FriendshipRequestCursorEntity
          >
        > {
  @override
  /// Builds the initial friendship-requests page.
  Future<
    PaginatedListState<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >
  >
  build() {
    return buildSearchPaginatedState();
  }

  @override
  /// Loads one friendship-requests page from the list usecase.
  Future<
    PaginatedPage<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >
  >
  loadPage({required int limit, FriendshipRequestCursorEntity? cursor}) async {
    final ListFriendshipRequestsUsecase usecase = ref.watch(
      listFriendshipRequestsUsecaseProvider,
    );
    final FriendshipRequestListPageEntity page = await usecase(
      search: searchQuery,
      limit: limit,
      cursor: cursor,
    );
    return PaginatedPage<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >(items: page.items, nextCursor: _cursorFromPage(page));
  }

  /// Refreshes the friendship-requests list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next friendship-requests page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  /// Creates a friendship request and inserts it at the top of local list.
  Future<FriendshipRequestListPageItemEntity> createRequest({
    required String addresseeFriendshipCode,
  }) async {
    final CreateFriendshipRequestUsecase usecase = ref.read(
      createFriendshipRequestUsecaseProvider,
    );

    final FriendshipRequestListPageItemEntity created = await usecase(
      addresseeFriendshipCode: addresseeFriendshipCode,
    );

    prependRequest(created);
    return created;
  }

  /// Accepts an incoming request with optimistic removal and rollback.
  Future<FriendshipListPageItemEntity> acceptRequest(
    FriendshipRequestListPageItemEntity request,
  ) async {
    if (request.direction != FriendshipRequestDirection.incoming) {
      throw ArgumentError.value(
        request.direction,
        'request.direction',
        'Only incoming requests can be accepted.',
      );
    }

    final PaginatedListState<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      throw StateError('Friendship requests must be loaded before accepting.');
    }

    final int originalIndex = _indexOfRequest(current.items, request);
    if (originalIndex < 0) {
      throw StateError('Cannot accept a request that is not currently listed.');
    }

    return runOptimisticUpdate<FriendshipListPageItemEntity>(
      apply:
          (
            PaginatedListState<
              FriendshipRequestListPageItemEntity,
              FriendshipRequestCursorEntity
            >
            state,
          ) {
            return _removeRequestFromState(state, request);
          },
      rollback:
          (
            PaginatedListState<
              FriendshipRequestListPageItemEntity,
              FriendshipRequestCursorEntity
            >
            state,
          ) {
            return _restoreRequestInState(
              state: state,
              request: request,
              originalIndex: originalIndex,
            );
          },
      operation: () async {
        final AcceptFriendshipRequestUsecase usecase = ref.read(
          acceptFriendshipRequestUsecaseProvider,
        );

        final FriendshipListPageItemEntity friendship = await usecase(
          requestId: request.id,
        );

        ref.read(friendshipsListProvider.notifier).upsertFriendship(friendship);
        return friendship;
      },
    );
  }

  /// Declines an incoming request with optimistic removal and rollback.
  Future<void> declineRequest(
    FriendshipRequestListPageItemEntity request,
  ) async {
    if (request.direction != FriendshipRequestDirection.incoming) {
      throw ArgumentError.value(
        request.direction,
        'request.direction',
        'Only incoming requests can be declined.',
      );
    }

    final PaginatedListState<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      throw StateError('Friendship requests must be loaded before declining.');
    }

    final int originalIndex = _indexOfRequest(current.items, request);
    if (originalIndex < 0) {
      return;
    }

    await runOptimisticUpdate<void>(
      apply:
          (
            PaginatedListState<
              FriendshipRequestListPageItemEntity,
              FriendshipRequestCursorEntity
            >
            state,
          ) {
            return _removeRequestFromState(state, request);
          },
      rollback:
          (
            PaginatedListState<
              FriendshipRequestListPageItemEntity,
              FriendshipRequestCursorEntity
            >
            state,
          ) {
            return _restoreRequestInState(
              state: state,
              request: request,
              originalIndex: originalIndex,
            );
          },
      operation: () async {
        final DeclineFriendshipRequestUsecase usecase = ref.read(
          declineFriendshipRequestUsecaseProvider,
        );
        await usecase(requestId: request.id);
      },
    );
  }

  /// Cancels an outgoing request with optimistic removal and rollback.
  Future<void> cancelRequest(
    FriendshipRequestListPageItemEntity request,
  ) async {
    if (request.direction != FriendshipRequestDirection.outgoing) {
      throw ArgumentError.value(
        request.direction,
        'request.direction',
        'Only outgoing requests can be canceled.',
      );
    }

    final PaginatedListState<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      throw StateError('Friendship requests must be loaded before canceling.');
    }

    final int originalIndex = _indexOfRequest(current.items, request);
    if (originalIndex < 0) {
      return;
    }

    await runOptimisticUpdate<void>(
      apply:
          (
            PaginatedListState<
              FriendshipRequestListPageItemEntity,
              FriendshipRequestCursorEntity
            >
            state,
          ) {
            return _removeRequestFromState(state, request);
          },
      rollback:
          (
            PaginatedListState<
              FriendshipRequestListPageItemEntity,
              FriendshipRequestCursorEntity
            >
            state,
          ) {
            return _restoreRequestInState(
              state: state,
              request: request,
              originalIndex: originalIndex,
            );
          },
      operation: () async {
        final CancelFriendshipRequestUsecase usecase = ref.read(
          cancelFriendshipRequestUsecaseProvider,
        );
        await usecase(requestId: request.id);
      },
    );
  }

  /// Inserts a request at the top of local state when the list is loaded.
  void prependRequest(FriendshipRequestListPageItemEntity request) {
    final PaginatedListState<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final List<FriendshipRequestListPageItemEntity> deduplicated = current.items
        .where(
          (FriendshipRequestListPageItemEntity item) =>
              !_isSameRequest(item, request),
        )
        .toList(growable: false);

    final List<FriendshipRequestListPageItemEntity> nextItems =
        <FriendshipRequestListPageItemEntity>[request, ...deduplicated];

    state =
        AsyncValue<
          PaginatedListState<
            FriendshipRequestListPageItemEntity,
            FriendshipRequestCursorEntity
          >
        >.data(
          current.copyWith(
            items: List<FriendshipRequestListPageItemEntity>.unmodifiable(
              nextItems,
            ),
          ),
        );
  }

  /// Finds the index of [request] in [items] using request identifiers.
  int _indexOfRequest(
    List<FriendshipRequestListPageItemEntity> items,
    FriendshipRequestListPageItemEntity request,
  ) {
    return items.indexWhere(
      (FriendshipRequestListPageItemEntity item) =>
          _isSameRequest(item, request),
    );
  }

  /// Returns a copy of [state] without [request].
  PaginatedListState<
    FriendshipRequestListPageItemEntity,
    FriendshipRequestCursorEntity
  >
  _removeRequestFromState(
    PaginatedListState<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >
    state,
    FriendshipRequestListPageItemEntity request,
  ) {
    final List<FriendshipRequestListPageItemEntity> nextItems = state.items
        .where(
          (FriendshipRequestListPageItemEntity item) =>
              !_isSameRequest(item, request),
        )
        .toList(growable: false);

    return state.copyWith(
      items: List<FriendshipRequestListPageItemEntity>.unmodifiable(nextItems),
    );
  }

  /// Restores [request] at [originalIndex] when absent.
  PaginatedListState<
    FriendshipRequestListPageItemEntity,
    FriendshipRequestCursorEntity
  >
  _restoreRequestInState({
    required PaginatedListState<
      FriendshipRequestListPageItemEntity,
      FriendshipRequestCursorEntity
    >
    state,
    required FriendshipRequestListPageItemEntity request,
    required int originalIndex,
  }) {
    final bool alreadyPresent = state.items.any(
      (FriendshipRequestListPageItemEntity item) =>
          _isSameRequest(item, request),
    );
    if (alreadyPresent) {
      return state;
    }

    final List<FriendshipRequestListPageItemEntity> nextItems =
        List<FriendshipRequestListPageItemEntity>.of(
          state.items,
          growable: true,
        );
    final int safeIndex = originalIndex.clamp(0, nextItems.length);
    nextItems.insert(safeIndex, request);

    return state.copyWith(
      items: List<FriendshipRequestListPageItemEntity>.unmodifiable(nextItems),
    );
  }

  /// Determines whether two request items represent the same logical request.
  bool _isSameRequest(
    FriendshipRequestListPageItemEntity left,
    FriendshipRequestListPageItemEntity right,
  ) {
    return left.id == right.id;
  }

  FriendshipRequestCursorEntity? _cursorFromPage(
    FriendshipRequestListPageEntity page,
  ) {
    final DateTime? nextCursorCreatedAt = page.nextCursorCreatedAt;
    final String? nextCursorId = page.nextCursorId;
    if (nextCursorCreatedAt == null || nextCursorId == null) {
      return null;
    }

    return FriendshipRequestCursorEntity(
      createdAt: nextCursorCreatedAt,
      id: nextCursorId,
    );
  }
}
