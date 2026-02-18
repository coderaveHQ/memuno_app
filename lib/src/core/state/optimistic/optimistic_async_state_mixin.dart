import 'package:riverpod/riverpod.dart';

/// Function signature used for optimistic state transformations.
typedef OptimisticStateTransformer<TState> = TState Function(TState state);

/// Mixin that adds optimistic apply/commit/rollback workflow to async notifiers.
mixin OptimisticAsyncStateMixin<TState> {
  /// Current async state managed by the target notifier.
  AsyncValue<TState> get state;

  /// Assigns a new async state on the target notifier.
  set state(AsyncValue<TState> value);

  /// Rollback handlers keyed by operation id.
  final Map<String, OptimisticStateTransformer<TState>>
  _rollbackHandlersByOperationId =
      <String, OptimisticStateTransformer<TState>>{};

  /// Monotonic counter used for deterministic operation ids.
  int _operationCounter = 0;

  /// Applies an optimistic update and stores its rollback transformer.
  String applyOptimisticUpdate({
    /// Transformer that applies the optimistic state mutation.
    required OptimisticStateTransformer<TState> apply,

    /// Transformer that reverts the optimistic state mutation.
    required OptimisticStateTransformer<TState> rollback,
  }) {
    final TState? current = state.asData?.value;
    if (current == null) {
      throw StateError(
        'Optimistic update requires a loaded AsyncData state value.',
      );
    }

    final String operationId = _nextOperationId();
    _rollbackHandlersByOperationId[operationId] = rollback;

    state = AsyncValue<TState>.data(apply(current));
    return operationId;
  }

  /// Marks an optimistic operation as permanently committed.
  void commitOptimisticUpdate(String operationId) {
    _rollbackHandlersByOperationId.remove(operationId);
  }

  /// Reverts an optimistic operation when the remote mutation fails.
  void rollbackOptimisticUpdate(String operationId) {
    final OptimisticStateTransformer<TState>? rollback =
        _rollbackHandlersByOperationId.remove(operationId);
    if (rollback == null) {
      return;
    }

    final TState? current = state.asData?.value;
    if (current == null) {
      return;
    }

    state = AsyncValue<TState>.data(rollback(current));
  }

  /// Executes an async operation with optimistic update and automatic rollback.
  Future<TResult> runOptimisticUpdate<TResult>({
    /// Transformer that applies the optimistic state mutation.
    required OptimisticStateTransformer<TState> apply,

    /// Transformer that reverts the optimistic state mutation.
    required OptimisticStateTransformer<TState> rollback,

    /// Remote async operation executed after local optimistic update.
    required Future<TResult> Function() operation,
  }) async {
    final String operationId = applyOptimisticUpdate(
      apply: apply,
      rollback: rollback,
    );

    try {
      final TResult result = await operation();
      commitOptimisticUpdate(operationId);
      return result;
    } catch (error, stackTrace) {
      rollbackOptimisticUpdate(operationId);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Generates the next unique optimistic operation id.
  String _nextOperationId() {
    _operationCounter += 1;
    final int nowMicros = DateTime.now().microsecondsSinceEpoch;
    return '$nowMicros-$_operationCounter';
  }
}
