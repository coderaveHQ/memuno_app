import 'dart:async';

import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:riverpod/riverpod.dart';

/// Mixin that adds debounced search workflow to async paginated notifiers.
///
/// Usage:
/// - Add this mixin beside [AsyncPaginationMixin] on the provider.
/// - Return [buildSearchPaginatedState] from `build()`.
/// - Read [searchQuery] in `loadPage()` and pass it to the usecase/repository.
/// - Call [applySearchDebounced] from UI listeners.
mixin AsyncPaginationSearchMixin<TItem, TCursor>
    on AsyncPaginationMixin<TItem, TCursor> {
  /// Ref from the host notifier, used for lifecycle cleanup.
  Ref get ref;

  String? _search;
  Timer? _searchDebounceTimer;
  bool _didRegisterDispose = false;

  /// Debounce delay applied to [applySearchDebounced].
  Duration get searchDebounceDuration => const Duration(milliseconds: 350);

  /// Current normalized search query applied to pagination calls.
  String? get searchQuery => _search;

  /// Initializes search state and builds the first paginated result.
  Future<PaginatedListState<TItem, TCursor>> buildSearchPaginatedState({
    String? initialSearch,
    bool overrideCurrentSearch = false,
  }) {
    final bool shouldAssignSearch =
        overrideCurrentSearch || initialSearch != null || _search == null;
    if (shouldAssignSearch) {
      _search = normalizeSearch(initialSearch);
    }

    _registerDispose();
    return buildPaginatedState();
  }

  /// Applies [search] immediately and reloads page 1 if query changed.
  Future<void> applySearch(String? search) async {
    _registerDispose();
    cancelPendingSearch();

    final String? normalizedSearch = normalizeSearch(search);
    if (normalizedSearch == _search) {
      return;
    }

    _search = normalizedSearch;
    await reloadFirstSearchPage();
  }

  /// Schedules [search] to be applied after [searchDebounceDuration].
  void applySearchDebounced(String? search) {
    _registerDispose();
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(searchDebounceDuration, () {
      unawaited(applySearch(search));
    });
  }

  /// Clears active search query and reloads page 1 when needed.
  Future<void> clearSearch() {
    return applySearch(null);
  }

  /// Cancels any pending debounced search update.
  void cancelPendingSearch() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = null;
  }

  /// Normalizes raw search input before assigning it to [searchQuery].
  String? normalizeSearch(String? value) {
    final String? trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  /// Replaces current state with a freshly loaded first page.
  Future<void> reloadFirstSearchPage() async {
    state = AsyncValue<PaginatedListState<TItem, TCursor>>.loading();

    state = await AsyncValue.guard<PaginatedListState<TItem, TCursor>>(() {
      return buildPaginatedState();
    });
  }

  void _registerDispose() {
    if (_didRegisterDispose) {
      return;
    }

    _didRegisterDispose = true;
    ref.onDispose(cancelPendingSearch);
  }
}
