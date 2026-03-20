import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/notifications/application/services/notification_target_route_mapper.dart';
import 'package:memuno_app/src/features/notifications/domain/entities/notification_navigation_target.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/mark_notification_read_usecase.dart';
import 'package:memuno_app/src/features/notifications/domain/usecases/resolve_notification_push_intent_usecase.dart';
import 'package:memuno_app/src/features/push_notifications/application/entities/push_incoming_message.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_local_notifications_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_messaging_gateway.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_platform_gateway.dart';

/// Handles push-tap intents and foreground local notifications.
final class PushNotificationsIntentService {
  /// Creates the service.
  PushNotificationsIntentService({
    required PushMessagingGateway pushMessagingGateway,
    required PushPlatformGateway pushPlatformGateway,
    required PushLocalNotificationsGateway pushLocalNotificationsGateway,
    required ResolveNotificationPushIntentUsecase
    resolveNotificationPushIntentUsecase,
    required NotificationTargetRouteMapper notificationTargetRouteMapper,
    required MarkNotificationReadUsecase markNotificationReadUsecase,
    required GoRouter router,
    required void Function() onUnreadCountChanged,
    required Logger logger,
  }) : _pushMessagingGateway = pushMessagingGateway,
       _pushPlatformGateway = pushPlatformGateway,
       _pushLocalNotificationsGateway = pushLocalNotificationsGateway,
       _resolveNotificationPushIntentUsecase =
           resolveNotificationPushIntentUsecase,
       _notificationTargetRouteMapper = notificationTargetRouteMapper,
       _markNotificationReadUsecase = markNotificationReadUsecase,
       _router = router,
       _onUnreadCountChanged = onUnreadCountChanged,
       _logger = logger;

  final PushMessagingGateway _pushMessagingGateway;
  final PushPlatformGateway _pushPlatformGateway;
  final PushLocalNotificationsGateway _pushLocalNotificationsGateway;
  final ResolveNotificationPushIntentUsecase
  _resolveNotificationPushIntentUsecase;
  final NotificationTargetRouteMapper _notificationTargetRouteMapper;
  final MarkNotificationReadUsecase _markNotificationReadUsecase;
  final GoRouter _router;
  final void Function() _onUnreadCountChanged;
  final Logger _logger;

  StreamSubscription<PushIncomingMessage>? _messageSubscription;
  StreamSubscription<PushIncomingMessage>? _messageOpenedSubscription;
  NotificationPushIntent? _pendingIntent;

  Future<void> _serializedOperation = Future<void>.value();

  bool _isInitialized = false;
  String? _currentUserId;
  String? _resolvedChannelName;
  String? _resolvedChannelDescription;

  /// Initializes push handlers and foreground local-notification callbacks.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      if (!_pushPlatformGateway.supportsPushNotifications) {
        _isInitialized = true;
        return;
      }

      await _pushLocalNotificationsGateway.initialize(
        onNotificationTap: _onForegroundNotificationTapped,
      );

      _messageSubscription = _pushMessagingGateway.onMessage.listen(
        (PushIncomingMessage message) {
          unawaited(_enqueue(() => _handleForegroundMessage(message)));
        },
        onError: (Object error, StackTrace stackTrace) {
          _logger.warn(
            message: 'Foreground push stream failed.',
            error: error,
            stackTrace: stackTrace,
          );
        },
      );

      _messageOpenedSubscription = _pushMessagingGateway.onMessageOpenedApp
          .listen(
            (PushIncomingMessage message) {
              unawaited(_enqueue(() => _handlePushTapMessage(message)));
            },
            onError: (Object error, StackTrace stackTrace) {
              _logger.warn(
                message: 'Push tap stream failed.',
                error: error,
                stackTrace: stackTrace,
              );
            },
          );

      final PushIncomingMessage? launchMessage = await _pushMessagingGateway
          .getInitialMessage();
      if (launchMessage != null) {
        unawaited(_enqueue(() => _handlePushTapMessage(launchMessage)));
      }

      _isInitialized = true;
    } catch (error, stackTrace) {
      _logger.error(
        message: 'Failed to initialize push intent service.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates auth state used for queued push intents.
  void handleAuthStateChange({required String? userId}) {
    final String? previousUserId = _currentUserId;
    _currentUserId = userId;

    if (previousUserId == null && userId != null && _pendingIntent != null) {
      final NotificationPushIntent pendingIntent = _pendingIntent!;
      _pendingIntent = null;
      unawaited(_enqueue(() => _executeIntent(pendingIntent)));
    }
  }

  /// Updates localized Android notification-channel copy.
  void handleResolvedLocale({
    required String channelName,
    required String channelDescription,
  }) {
    final String normalizedName = channelName.trim();
    final String normalizedDescription = channelDescription.trim();
    if (normalizedName.isEmpty || normalizedDescription.isEmpty) {
      return;
    }

    if (_resolvedChannelName == normalizedName &&
        _resolvedChannelDescription == normalizedDescription) {
      return;
    }

    _resolvedChannelName = normalizedName;
    _resolvedChannelDescription = normalizedDescription;

    _pushLocalNotificationsGateway.configureChannelLocalization(
      channelLocalization: PushNotificationChannelLocalization(
        name: normalizedName,
        description: normalizedDescription,
      ),
    );
  }

  /// Releases stream subscriptions.
  Future<void> dispose() async {
    await _messageSubscription?.cancel();
    await _messageOpenedSubscription?.cancel();
  }

  Future<void> _enqueue(Future<void> Function() operation) {
    _serializedOperation = _serializedOperation.then((_) async {
      try {
        await operation();
      } catch (error, stackTrace) {
        _logger.warn(
          message: 'Push intent operation failed.',
          error: error,
          stackTrace: stackTrace,
        );
      }
    });

    return _serializedOperation;
  }

  Future<void> _handleForegroundMessage(PushIncomingMessage message) async {
    final String normalizedTitle = message.title?.trim() ?? '';
    final String normalizedBody = message.body?.trim() ?? '';

    if (normalizedTitle.isEmpty && normalizedBody.isEmpty) {
      return;
    }

    final String? messageNotificationId = message.data['notification_id']
        ?.trim();
    final String notificationId =
        messageNotificationId == null || messageNotificationId.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : messageNotificationId;

    await _pushLocalNotificationsGateway.showForegroundNotification(
      notificationId: notificationId,
      title: normalizedTitle.isEmpty ? null : normalizedTitle,
      body: normalizedBody.isEmpty ? normalizedTitle : normalizedBody,
      data: message.data,
      imageUrl: message.imageUrl ?? message.data['push_image_url'],
    );
  }

  Future<void> _handlePushTapMessage(PushIncomingMessage message) async {
    if (message.data.isEmpty) {
      return;
    }

    final NotificationPushIntent intent = _resolveNotificationPushIntentUsecase
        .fromPushData(message.data);

    if (_currentUserId == null) {
      _pendingIntent = intent;
      _navigateToSignIn();
      return;
    }

    await _executeIntent(intent);
  }

  void _onForegroundNotificationTapped(Map<String, String> data) {
    if (data.isEmpty) {
      return;
    }

    unawaited(
      _enqueue(() async {
        final NotificationPushIntent intent =
            _resolveNotificationPushIntentUsecase.fromPushData(data);
        if (_currentUserId == null) {
          _pendingIntent = intent;
          _navigateToSignIn();
          return;
        }

        await _executeIntent(intent);
      }),
    );
  }

  Future<void> _executeIntent(NotificationPushIntent intent) async {
    await _markAsRead(intent.notificationId);

    final String targetLocation = _notificationTargetRouteMapper.toLocation(
      intent.target,
    );

    try {
      await _router.push(targetLocation);
    } catch (error, stackTrace) {
      _logger.warn(
        message:
            'Push target navigation failed. Falling back to notifications.',
        error: error,
        stackTrace: stackTrace,
      );
      await _router.push(
        _notificationTargetRouteMapper.notificationsLocation(),
      );
    }
  }

  Future<void> _markAsRead(String? notificationId) async {
    final String? normalizedNotificationId = notificationId?.trim();
    if (normalizedNotificationId == null || normalizedNotificationId.isEmpty) {
      return;
    }

    try {
      await _markNotificationReadUsecase(
        notificationId: normalizedNotificationId,
      );
      _onUnreadCountChanged();
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to mark notification as read from push intent.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _navigateToSignIn() {
    final Uri currentUri = _router.routeInformationProvider.value.uri;
    final String signInLocation = const SignInRoute().location;

    if (currentUri.path == Uri.parse(signInLocation).path) {
      return;
    }

    _router.go(signInLocation);
  }
}
