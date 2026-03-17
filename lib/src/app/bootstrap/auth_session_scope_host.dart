import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/core/utils/logger.dart';

/// Session-bound state for rotating the root provider scope.
@immutable
final class AuthSessionScopeState {
  /// Creates one immutable snapshot.
  const AuthSessionScopeState({
    required this.userId,
    required this.scopeVersion,
  });

  /// Creates the initial session scope state.
  factory AuthSessionScopeState.initial({required String? userId}) {
    return AuthSessionScopeState(userId: userId, scopeVersion: 0);
  }

  /// Current authenticated user id (null when signed out).
  final String? userId;

  /// Monotonic version used as a [ProviderScope] key.
  final int scopeVersion;
}

/// Reduces auth user-id events into provider-scope state.
///
/// Rotation rule:
/// - unchanged user id => keep the current scope version
/// - changed user id => increment scope version to force scope recreation
AuthSessionScopeState reduceAuthSessionScopeState({
  required AuthSessionScopeState current,
  required String? nextUserId,
}) {
  if (current.userId == nextUserId) {
    return current;
  }

  return AuthSessionScopeState(
    userId: nextUserId,
    scopeVersion: current.scopeVersion + 1,
  );
}

/// Hosts a keyed root [ProviderScope] that resets on auth identity changes.
final class AuthSessionScopeHost extends StatefulWidget {
  /// Creates the host.
  const AuthSessionScopeHost({
    super.key,
    required this.initialUserId,
    required this.authUserIdChanges,
    required this.overrides,
    required this.child,
  });

  /// Initial auth user id at app startup (null when signed out).
  final String? initialUserId;

  /// Stream of auth user-id updates.
  final Stream<String?> authUserIdChanges;

  /// Provider overrides applied to each recreated root scope.
  final List<Object> overrides;

  /// App subtree rendered inside the scope.
  final Widget child;

  @override
  State<AuthSessionScopeHost> createState() => _AuthSessionScopeHostState();
}

class _AuthSessionScopeHostState extends State<AuthSessionScopeHost> {
  late AuthSessionScopeState _scopeState;
  StreamSubscription<String?>? _authUserIdSubscription;

  @override
  void initState() {
    super.initState();
    _scopeState = AuthSessionScopeState.initial(userId: widget.initialUserId);
    _bindAuthUserIdStream(widget.authUserIdChanges);
  }

  @override
  void didUpdateWidget(covariant AuthSessionScopeHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.authUserIdChanges != widget.authUserIdChanges) {
      _authUserIdSubscription?.cancel();
      _bindAuthUserIdStream(widget.authUserIdChanges);
    }
  }

  @override
  void dispose() {
    _authUserIdSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: ValueKey<int>(_scopeState.scopeVersion),
      overrides: widget.overrides.cast(),
      child: widget.child,
    );
  }

  void _bindAuthUserIdStream(Stream<String?> stream) {
    _authUserIdSubscription = stream.listen(
      _handleAuthUserIdChange,
      onError: (Object error, StackTrace stackTrace) {
        Logger.instance.warn(
          message: 'Failed to observe auth user-id stream.',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
  }

  void _handleAuthUserIdChange(String? nextUserId) {
    final AuthSessionScopeState nextState = reduceAuthSessionScopeState(
      current: _scopeState,
      nextUserId: nextUserId,
    );

    if (identical(nextState, _scopeState)) {
      return;
    }

    Logger.instance.info(
      message:
          'Auth session boundary changed. Recreating ProviderScope '
          '(previousUserId=${_formatUserId(_scopeState.userId)}, '
          'nextUserId=${_formatUserId(nextState.userId)}).',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _scopeState = nextState;
    });
  }

  String _formatUserId(String? userId) {
    return userId ?? '<signed-out>';
  }
}
