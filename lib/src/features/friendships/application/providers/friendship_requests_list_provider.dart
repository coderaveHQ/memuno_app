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
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_cursor_entity.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_direction.dart';
import 'package:memuno_app/src/features/friendships/domain/entities/friendship_request_entity.dart';
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
          FriendshipRequestEntity,
          FriendshipRequestCursorEntity
        >,
        AsyncPaginationSearchMixin<
          FriendshipRequestEntity,
          FriendshipRequestCursorEntity
        >,
        OptimisticAsyncStateMixin<
          PaginatedListState<
            FriendshipRequestEntity,
            FriendshipRequestCursorEntity
          >
        > {
  @override
  /// Builds the initial friendship-requests page.
  Future<
    PaginatedListState<FriendshipRequestEntity, FriendshipRequestCursorEntity>
  >
  build() {
    return buildSearchPaginatedState();
  }

  @override
  /// Loads one friendship-requests page from the list usecase.
  Future<PaginatedPage<FriendshipRequestEntity, FriendshipRequestCursorEntity>>
  loadPage({required int limit, FriendshipRequestCursorEntity? cursor}) async {
    final ListFriendshipRequestsUsecase usecase = ref.watch(
      listFriendshipRequestsUsecaseProvider,
    );
    return usecase(search: searchQuery, limit: limit, cursor: cursor);
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
  Future<FriendshipRequestEntity> createRequest({
    required String addresseeFriendshipCode,
  }) async {
    final CreateFriendshipRequestUsecase usecase = ref.read(
      createFriendshipRequestUsecaseProvider,
    );

    final FriendshipRequestEntity created = await usecase(
      addresseeFriendshipCode: addresseeFriendshipCode,
    );

    prependRequest(created);
    return created;
  }

  /// Accepts an incoming request with optimistic removal and rollback.
  Future<FriendshipEntity> acceptRequest(
    FriendshipRequestEntity request,
  ) async {
    if (request.direction != FriendshipRequestDirection.incoming) {
      throw ArgumentError.value(
        request.direction,
        'request.direction',
        'Only incoming requests can be accepted.',
      );
    }

    final PaginatedListState<
      FriendshipRequestEntity,
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

    return runOptimisticUpdate<FriendshipEntity>(
      apply:
          (
            PaginatedListState<
              FriendshipRequestEntity,
              FriendshipRequestCursorEntity
            >
            state,
          ) {
            return _removeRequestFromState(state, request);
          },
      rollback:
          (
            PaginatedListState<
              FriendshipRequestEntity,
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

        final FriendshipEntity friendship = await usecase(
          requestId: request.id,
        );

        ref.read(friendshipsListProvider.notifier).upsertFriendship(friendship);
        return friendship;
      },
    );
  }

  /// Declines an incoming request with optimistic removal and rollback.
  Future<void> declineRequest(FriendshipRequestEntity request) async {
    if (request.direction != FriendshipRequestDirection.incoming) {
      throw ArgumentError.value(
        request.direction,
        'request.direction',
        'Only incoming requests can be declined.',
      );
    }

    final PaginatedListState<
      FriendshipRequestEntity,
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
              FriendshipRequestEntity,
              FriendshipRequestCursorEntity
            >
            state,
          ) {
            return _removeRequestFromState(state, request);
          },
      rollback:
          (
            PaginatedListState<
              FriendshipRequestEntity,
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
  Future<void> cancelRequest(FriendshipRequestEntity request) async {
    if (request.direction != FriendshipRequestDirection.outgoing) {
      throw ArgumentError.value(
        request.direction,
        'request.direction',
        'Only outgoing requests can be canceled.',
      );
    }

    final PaginatedListState<
      FriendshipRequestEntity,
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
              FriendshipRequestEntity,
              FriendshipRequestCursorEntity
            >
            state,
          ) {
            return _removeRequestFromState(state, request);
          },
      rollback:
          (
            PaginatedListState<
              FriendshipRequestEntity,
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
  void prependRequest(FriendshipRequestEntity request) {
    final PaginatedListState<
      FriendshipRequestEntity,
      FriendshipRequestCursorEntity
    >?
    current = state.asData?.value;
    if (current == null) {
      return;
    }

    final List<FriendshipRequestEntity> deduplicated = current.items
        .where((FriendshipRequestEntity item) => !_isSameRequest(item, request))
        .toList(growable: false);

    final List<FriendshipRequestEntity> nextItems = <FriendshipRequestEntity>[
      request,
      ...deduplicated,
    ];

    state =
        AsyncValue<
          PaginatedListState<
            FriendshipRequestEntity,
            FriendshipRequestCursorEntity
          >
        >.data(
          current.copyWith(
            items: List<FriendshipRequestEntity>.unmodifiable(nextItems),
          ),
        );
  }

  /// Finds the index of [request] in [items] using request identifiers.
  int _indexOfRequest(
    List<FriendshipRequestEntity> items,
    FriendshipRequestEntity request,
  ) {
    return items.indexWhere(
      (FriendshipRequestEntity item) => _isSameRequest(item, request),
    );
  }

  /// Returns a copy of [state] without [request].
  PaginatedListState<FriendshipRequestEntity, FriendshipRequestCursorEntity>
  _removeRequestFromState(
    PaginatedListState<FriendshipRequestEntity, FriendshipRequestCursorEntity>
    state,
    FriendshipRequestEntity request,
  ) {
    final List<FriendshipRequestEntity> nextItems = state.items
        .where((FriendshipRequestEntity item) => !_isSameRequest(item, request))
        .toList(growable: false);

    return state.copyWith(
      items: List<FriendshipRequestEntity>.unmodifiable(nextItems),
    );
  }

  /// Restores [request] at [originalIndex] when absent.
  PaginatedListState<FriendshipRequestEntity, FriendshipRequestCursorEntity>
  _restoreRequestInState({
    required PaginatedListState<
      FriendshipRequestEntity,
      FriendshipRequestCursorEntity
    >
    state,
    required FriendshipRequestEntity request,
    required int originalIndex,
  }) {
    final bool alreadyPresent = state.items.any(
      (FriendshipRequestEntity item) => _isSameRequest(item, request),
    );
    if (alreadyPresent) {
      return state;
    }

    final List<FriendshipRequestEntity> nextItems =
        List<FriendshipRequestEntity>.of(state.items, growable: true);
    final int safeIndex = originalIndex.clamp(0, nextItems.length);
    nextItems.insert(safeIndex, request);

    return state.copyWith(
      items: List<FriendshipRequestEntity>.unmodifiable(nextItems),
    );
  }

  /// Determines whether two request items represent the same logical request.
  bool _isSameRequest(
    FriendshipRequestEntity left,
    FriendshipRequestEntity right,
  ) {
    return left.id == right.id;
  }
}
