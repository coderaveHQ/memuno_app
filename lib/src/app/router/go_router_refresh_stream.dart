import 'dart:async';

import 'package:flutter/foundation.dart';

/// ChangeNotifier that bridges a Stream to GoRouter's refreshListenable.
///
/// Why this exists:
/// - GoRouter requires a Listenable for refresh triggers.
/// - We want to use a Stream (auth state changes) as the refresh source.
/// - This adapter listens to the stream and notifies GoRouter on every emit.
///
/// Usage:
/// ```dart
/// final notifier = GoRouterRefreshStream(authStateStream);
/// GoRouter(refreshListenable: notifier, ...);
/// ```
final class GoRouterRefreshStream<T> extends ChangeNotifier {
  /// Creates the refresh stream adapter.
  GoRouterRefreshStream(
    /// Stream whose emissions should trigger router refreshes.
    Stream<T> stream,
  ) {
    _subscription = stream.listen((_) {
      // Notify GoRouter to re-run redirect logic.
      notifyListeners();
    });
  }

  /// Subscription used to listen to the source stream.
  late final StreamSubscription<T> _subscription;

  /// Cancels the stream subscription and disposes the notifier.
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
