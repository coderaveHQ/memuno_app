import 'package:flutter/foundation.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_state_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_router_refresh_provider.g.dart';

/// Provides the GoRouter refreshListenable (notifies on auth state changes).
@Riverpod(keepAlive: true)
ChangeNotifier authRouterRefresh(Ref ref) {
  /// Notifier instance used as a GoRouter refreshListenable.
  final _AuthRouterRefreshNotifier notifier = _AuthRouterRefreshNotifier();

  // Trigger a router refresh whenever auth state updates.
  ref.listen<AsyncValue<AuthStateEntity>>(authStateProvider, (
    AsyncValue<AuthStateEntity>? previous,
    AsyncValue<AuthStateEntity> next,
  ) {
    notifier.notify();
  });

  // Dispose the notifier when the provider is disposed.
  ref.onDispose(() {
    notifier.dispose();
  });

  return notifier;
}

/// Internal notifier that exposes a safe trigger method.
final class _AuthRouterRefreshNotifier extends ChangeNotifier {
  /// Creates the notifier.
  _AuthRouterRefreshNotifier();

  /// Notifies listeners that a router refresh is required.
  void notify() {
    notifyListeners();
  }
}
