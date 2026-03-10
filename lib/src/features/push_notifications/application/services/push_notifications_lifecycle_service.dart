import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/push_notifications/application/entities/push_auth_lifecycle_event.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_messaging_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_platform_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_sync_state_store.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_platform.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_token_deactivation_reason.dart';
import 'package:memuno_app/src/features/push_notifications/domain/usecases/deactivate_current_device_push_token_usecase.dart';
import 'package:memuno_app/src/features/push_notifications/domain/usecases/register_current_device_push_token_usecase.dart';

/// Coordinates push-token synchronization and permissions lifecycle.
final class PushNotificationsLifecycleService {
  /// Creates the lifecycle service.
  PushNotificationsLifecycleService({
    required PushMessagingGateway pushMessagingGateway,
    required PushPlatformGateway pushPlatformGateway,
    required PushSyncStateStore pushSyncStateStore,
    required RegisterCurrentDevicePushTokenUsecase
    registerCurrentDevicePushTokenUsecase,
    required DeactivateCurrentDevicePushTokenUsecase
    deactivateCurrentDevicePushTokenUsecase,
    required Logger logger,
  }) : _pushMessagingGateway = pushMessagingGateway,
       _pushPlatformGateway = pushPlatformGateway,
       _pushSyncStateStore = pushSyncStateStore,
       _registerCurrentDevicePushTokenUsecase =
           registerCurrentDevicePushTokenUsecase,
       _deactivateCurrentDevicePushTokenUsecase =
           deactivateCurrentDevicePushTokenUsecase,
       _logger = logger;

  final PushMessagingGateway _pushMessagingGateway;
  final PushPlatformGateway _pushPlatformGateway;
  final PushSyncStateStore _pushSyncStateStore;
  final RegisterCurrentDevicePushTokenUsecase
  _registerCurrentDevicePushTokenUsecase;
  final DeactivateCurrentDevicePushTokenUsecase
  _deactivateCurrentDevicePushTokenUsecase;
  final Logger _logger;

  StreamSubscription<String>? _tokenRefreshSubscription;
  AppLifecycleListener? _appLifecycleListener;

  Future<void> _serializedOperation = Future<void>.value();

  bool _isInitialized = false;
  String? _currentUserId;
  Locale _resolvedLocale = WidgetsBinding.instance.platformDispatcher.locale;

  /// Initializes push handlers and app-lifecycle hooks.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    try {
      if (!_pushPlatformGateway.supportsPushNotifications) {
        _isInitialized = true;
        _logger.info(
          message:
              'Skipping push lifecycle initialization on unsupported platform.',
        );
        return;
      }

      if (_pushPlatformGateway.isIOS) {
        await _pushMessagingGateway.configureForegroundPresentationOptions(
          alert: false,
          badge: false,
          sound: false,
        );
      }

      _tokenRefreshSubscription = _pushMessagingGateway.onTokenRefresh.listen(
        _onTokenRefreshed,
        onError: (Object error, StackTrace stackTrace) {
          _logger.warn(
            message: 'FCM token-refresh stream failed.',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );

      _appLifecycleListener = AppLifecycleListener(onResume: _onAppResumed);

      _isInitialized = true;
      retryPendingSync();
    } catch (error, stackTrace) {
      _logger.error(
        message: 'Failed to initialize push notifications lifecycle.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates the resolved app locale used for token synchronization.
  void handleResolvedLocale(Locale locale) {
    if (_resolvedLocale == locale) {
      return;
    }

    _resolvedLocale = locale;
    if (_currentUserId != null) {
      unawaited(_enqueue(_syncCurrentDeviceToken));
    }
  }

  /// Handles auth-state transitions to trigger token synchronization.
  void handleAuthStateChange({
    required PushAuthLifecycleEvent event,
    required String? userId,
  }) {
    final String? previousUserId = _currentUserId;
    _currentUserId = userId;

    if (event == PushAuthLifecycleEvent.sessionEnded &&
        previousUserId != null) {
      unawaited(
        _enqueue(() async {
          await _deactivateCurrentDeviceToken(
            reason: PushTokenDeactivationReason.signedOut,
          );
        }),
      );
      return;
    }

    if (event == PushAuthLifecycleEvent.sessionAvailable && userId != null) {
      unawaited(_enqueue(_syncCurrentDeviceToken));
    }
  }

  /// Retries a previously failed token sync when pending.
  void retryPendingSync() {
    unawaited(_enqueue(_retryPendingSyncInternal));
  }

  /// Releases stream subscriptions and lifecycle hooks.
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _appLifecycleListener?.dispose();
  }

  /// Waits until all currently queued operations have completed.
  Future<void> waitForIdle() {
    return _serializedOperation;
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    _serializedOperation = _serializedOperation.then((_) async {
      try {
        await operation();
      } catch (error, stackTrace) {
        _logger.warn(
          message: 'Push lifecycle operation failed.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });

    return _serializedOperation;
  }

  void _onAppResumed() {
    retryPendingSync();
  }

  void _onTokenRefreshed(String token) {
    if (_currentUserId == null) {
      return;
    }

    unawaited(
      _enqueue(() async {
        await _syncCurrentDeviceToken(tokenOverride: token);
      }),
    );
  }

  Future<void> _retryPendingSyncInternal() async {
    if (_currentUserId == null) {
      return;
    }

    if (!_pushSyncStateStore.loadSyncPending()) {
      return;
    }

    await _syncCurrentDeviceToken();
  }

  Future<void> _syncCurrentDeviceToken({String? tokenOverride}) async {
    if (_currentUserId == null ||
        !_pushPlatformGateway.supportsPushNotifications) {
      return;
    }
    try {
      final bool permissionGranted = await _pushMessagingGateway
          .requestPermission();
      if (!permissionGranted) {
        await _deactivateCurrentDeviceToken(
          reason: PushTokenDeactivationReason.permissionRevoked,
        );
        return;
      }

      final PushPlatform? platform = _pushPlatformGateway.resolvePushPlatform();
      if (platform == null) {
        return;
      }

      final String? token =
          tokenOverride ?? await _pushMessagingGateway.getToken();
      if (token == null || token.trim().isEmpty) {
        await _pushSyncStateStore.saveSyncPending(true);
        _logger.warn(message: 'FCM token not available yet. Scheduling retry.');
        return;
      }

      await _registerCurrentDevicePushTokenUsecase(
        fcmToken: token.trim(),
        platform: platform,
        languageCode: _resolvedLocale.languageCode.toLowerCase(),
        countryCode: _resolvedLocale.countryCode?.toUpperCase(),
      );
      await _pushSyncStateStore.saveSyncPending(false);
    } catch (error, stackTrace) {
      await _pushSyncStateStore.saveSyncPending(true);
      _logger.warn(
        message: 'Push token sync failed. Marking retry as pending.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _deactivateCurrentDeviceToken({
    required PushTokenDeactivationReason reason,
  }) async {
    if (!_pushPlatformGateway.supportsPushNotifications) {
      return;
    }

    try {
      await _deactivateCurrentDevicePushTokenUsecase(reason: reason);
      await _pushSyncStateStore.saveSyncPending(false);
    } catch (error, stackTrace) {
      await _pushSyncStateStore.saveSyncPending(true);
      _logger.warn(
        message: 'Push token deactivation failed. Scheduling retry.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
