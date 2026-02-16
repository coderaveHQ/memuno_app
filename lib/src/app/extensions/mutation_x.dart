import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Convenience helpers for Riverpod mutations.
extension MutationX<T> on Mutation<T> {
  /// Runs a mutation and swallows rethrown errors after state updates.
  Future<T?> runSafely(
    WidgetRef ref,
    Future<T> Function(MutationTransaction tx) cb,
  ) async {
    try {
      return await run(ref, cb);
    } catch (_) {
      return null;
    }
  }
}
