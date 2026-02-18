import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:riverpod/riverpod.dart';

/// Mixin that adds cursor-based pagination workflow to async notifiers.
mixin AsyncPaginationMixin<TItem, TCursor> {
  /// Current async state managed by the target notifier.
  AsyncValue<PaginatedListState<TItem, TCursor>> get state;

  /// Assigns a new async state on the target notifier.
  set state(AsyncValue<PaginatedListState<TItem, TCursor>> value);

  /// Number of rows requested per page.
  int get pageSize => 30;

  /// Loads one page for the given [cursor] and [limit].
  Future<PaginatedPage<TItem, TCursor>> loadPage({
    /// Requested backend page size.
    required int limit,

    /// Cursor identifying where to continue fetching.
    TCursor? cursor,
  });

  /// Builds the initial paginated state for notifier `build()`.
  Future<PaginatedListState<TItem, TCursor>> buildPaginatedState() async {
    final PaginatedPage<TItem, TCursor> page = await loadPage(limit: pageSize);
    return PaginatedListState<TItem, TCursor>.fromInitialPage(
      page: page,
      requestedLimit: pageSize,
    );
  }

  /// Reloads the first page while preserving current items until completion.
  Future<void> refreshPage() async {
    final PaginatedListState<TItem, TCursor>? current = state.asData?.value;

    if (current != null && current.isRefreshing) {
      return;
    }

    if (current != null) {
      state = AsyncValue<PaginatedListState<TItem, TCursor>>.data(
        current.copyWith(isRefreshing: true, isLoadingMore: false),
      );
    }

    try {
      final PaginatedPage<TItem, TCursor> page = await loadPage(
        limit: pageSize,
      );

      state = AsyncValue<PaginatedListState<TItem, TCursor>>.data(
        PaginatedListState<TItem, TCursor>.fromInitialPage(
          page: page,
          requestedLimit: pageSize,
        ),
      );
    } catch (error, stackTrace) {
      if (current != null) {
        state = AsyncValue<PaginatedListState<TItem, TCursor>>.data(
          current.copyWith(isRefreshing: false, isLoadingMore: false),
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Loads and appends the next page when available.
  Future<void> loadNextPage() async {
    final PaginatedListState<TItem, TCursor>? current = state.asData?.value;

    if (current == null ||
        !current.hasMore ||
        current.isLoadingMore ||
        current.isRefreshing) {
      return;
    }

    state = AsyncValue<PaginatedListState<TItem, TCursor>>.data(
      current.copyWith(isLoadingMore: true),
    );

    try {
      final PaginatedPage<TItem, TCursor> page = await loadPage(
        limit: pageSize,
        cursor: current.nextCursor,
      );

      final PaginatedListState<TItem, TCursor> latest =
          state.asData?.value ?? current;
      final PaginatedListState<TItem, TCursor> merged = latest
          .copyWith(isLoadingMore: false)
          .appendPage(page: page, requestedLimit: pageSize);

      state = AsyncValue<PaginatedListState<TItem, TCursor>>.data(merged);
    } catch (error, stackTrace) {
      final PaginatedListState<TItem, TCursor> latest =
          state.asData?.value ?? current;
      state = AsyncValue<PaginatedListState<TItem, TCursor>>.data(
        latest.copyWith(isLoadingMore: false),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
