import 'package:flutter/foundation.dart';

/// Container representing one fetched page of paginated items.
@immutable
final class PaginatedPage<TItem, TCursor> {
  /// Creates a paginated page container.
  const PaginatedPage({
    /// Items fetched for the requested page.
    required this.items,

    /// Cursor value used to request the next page.
    this.nextCursor,
  });

  /// Items fetched for the requested page.
  final List<TItem> items;

  /// Cursor value used to request the next page.
  final TCursor? nextCursor;
}
