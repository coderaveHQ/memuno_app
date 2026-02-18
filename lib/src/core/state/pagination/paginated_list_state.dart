import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';

/// Sentinel used by [copyWith] to detect omitted cursor assignments.
const Object _noCursor = Object();

/// Immutable UI state for a cursor-paginated list.
@immutable
final class PaginatedListState<TItem, TCursor> {
  /// Creates a paginated list state.
  const PaginatedListState({
    /// Currently rendered items.
    required this.items,

    /// Cursor used for requesting the next page.
    required this.nextCursor,

    /// Whether requesting another page is currently possible.
    required this.hasMore,

    /// Whether a pull-to-refresh request is currently running.
    this.isRefreshing = false,

    /// Whether a load-more request is currently running.
    this.isLoadingMore = false,
  });

  /// Creates state from the first loaded page.
  factory PaginatedListState.fromInitialPage({
    /// First fetched page payload.
    required PaginatedPage<TItem, TCursor> page,

    /// Requested backend page size.
    required int requestedLimit,
  }) {
    assert(requestedLimit > 0, 'requestedLimit must be greater than zero.');

    return PaginatedListState<TItem, TCursor>(
      items: List<TItem>.unmodifiable(page.items),
      nextCursor: page.nextCursor,
      hasMore: page.items.length >= requestedLimit && page.nextCursor != null,
    );
  }

  /// Currently rendered items.
  final List<TItem> items;

  /// Cursor used for requesting the next page.
  final TCursor? nextCursor;

  /// Whether requesting another page is currently possible.
  final bool hasMore;

  /// Whether a pull-to-refresh request is currently running.
  final bool isRefreshing;

  /// Whether a load-more request is currently running.
  final bool isLoadingMore;

  /// Creates a modified copy of the state.
  PaginatedListState<TItem, TCursor> copyWith({
    /// Updated item list.
    List<TItem>? items,

    /// Updated cursor value.
    Object? nextCursor = _noCursor,

    /// Updated `hasMore` value.
    bool? hasMore,

    /// Updated refresh flag.
    bool? isRefreshing,

    /// Updated load-more flag.
    bool? isLoadingMore,
  }) {
    return PaginatedListState<TItem, TCursor>(
      items: items ?? this.items,
      nextCursor: nextCursor == _noCursor
          ? this.nextCursor
          : nextCursor as TCursor?,
      hasMore: hasMore ?? this.hasMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  /// Appends a newly fetched page and recomputes pagination flags.
  PaginatedListState<TItem, TCursor> appendPage({
    /// Next fetched page payload.
    required PaginatedPage<TItem, TCursor> page,

    /// Requested backend page size.
    required int requestedLimit,
  }) {
    assert(requestedLimit > 0, 'requestedLimit must be greater than zero.');

    final List<TItem> mergedItems = List<TItem>.unmodifiable(<TItem>[
      ...items,
      ...page.items,
    ]);

    return copyWith(
      items: mergedItems,
      nextCursor: page.nextCursor,
      hasMore: page.items.length >= requestedLimit && page.nextCursor != null,
      isLoadingMore: false,
      isRefreshing: false,
    );
  }
}
