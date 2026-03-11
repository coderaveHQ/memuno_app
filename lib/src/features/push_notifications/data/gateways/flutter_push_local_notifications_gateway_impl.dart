import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:memuno_app/src/features/push_notifications/application/ports/push_local_notifications_gateway.dart';

/// `flutter_local_notifications` implementation of [PushLocalNotificationsGateway].
final class FlutterPushLocalNotificationsGatewayImpl
    implements PushLocalNotificationsGateway {
  /// Creates the gateway.
  FlutterPushLocalNotificationsGatewayImpl({
    required FlutterLocalNotificationsPlugin localNotificationsPlugin,
  }) : _localNotificationsPlugin = localNotificationsPlugin;

  static const String _channelId = 'memuno_foreground_messages';
  static const String _channelName = 'Memuno notifications';
  static const String _channelDescription =
      'General notifications for the Memuno app.';

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin;
  bool _isInitialized = false;
  void Function(Map<String, String> data)? _tapHandler;

  @override
  Future<void> initialize({
    required void Function(Map<String, String> data) onNotificationTap,
  }) async {
    _tapHandler = onNotificationTap;

    if (_isInitialized) {
      return;
    }

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            _handleNotificationTap(notificationResponse.payload);
          },
    );

    _isInitialized = true;
  }

  @override
  Future<void> showForegroundNotification({
    required String notificationId,
    required String? title,
    required String body,
    required Map<String, String> data,
    required String? imageUrl,
  }) async {
    if (!_isInitialized) {
      return;
    }

    final String normalizedTitle = title?.trim() ?? '';
    final String normalizedBody = body.trim();
    if (normalizedTitle.isEmpty && normalizedBody.isEmpty) {
      return;
    }

    final String displayBody = normalizedBody.isEmpty
        ? normalizedTitle
        : normalizedBody;

    final String? imagePath = await _downloadImageToTemporaryFile(
      imageUrl: imageUrl,
      notificationId: notificationId,
    );

    final NotificationDetails details = NotificationDetails(
      android: _androidDetails(imagePath),
      iOS: _iosDetails(imagePath),
    );

    await _localNotificationsPlugin.show(
      id: _toNotificationIntegerId(notificationId),
      title: normalizedTitle.isEmpty ? null : normalizedTitle,
      body: displayBody,
      notificationDetails: details,
      payload: jsonEncode(data),
    );
  }

  AndroidNotificationDetails _androidDetails(String? imagePath) {
    final StyleInformation? styleInformation = imagePath == null
        ? null
        : BigPictureStyleInformation(
            FilePathAndroidBitmap(imagePath),
            largeIcon: FilePathAndroidBitmap(imagePath),
          );

    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: styleInformation,
    );
  }

  DarwinNotificationDetails _iosDetails(String? imagePath) {
    final List<DarwinNotificationAttachment> attachments = imagePath == null
        ? const <DarwinNotificationAttachment>[]
        : <DarwinNotificationAttachment>[
            DarwinNotificationAttachment(imagePath),
          ];

    return DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: true,
      attachments: attachments,
    );
  }

  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return;
    }

    try {
      final Object? parsed = jsonDecode(payload);
      if (parsed is! Map) {
        return;
      }

      final Map<String, String> data = Map<String, String>.from(
        parsed.map(
          (Object? key, Object? value) =>
              MapEntry(key.toString(), value.toString()),
        ),
      );

      _tapHandler?.call(data);
    } catch (_) {
      // Ignore malformed payloads from stale local notifications.
    }
  }

  Future<String?> _downloadImageToTemporaryFile({
    required String? imageUrl,
    required String notificationId,
  }) async {
    if (imageUrl == null || imageUrl.trim().isEmpty) {
      return null;
    }

    final Uri? uri = Uri.tryParse(imageUrl);
    if (uri == null) {
      return null;
    }

    HttpClient? client;
    try {
      client = HttpClient();
      final HttpClientRequest request = await client.getUrl(uri);
      final HttpClientResponse response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final BytesBuilder bytesBuilder = BytesBuilder(copy: false);
      await for (final List<int> chunk in response) {
        bytesBuilder.add(chunk);
      }

      final Uint8List bytes = bytesBuilder.takeBytes();
      if (bytes.isEmpty) {
        return null;
      }

      final String extension = _resolveImageExtension(uri);
      final String filePath =
          '${Directory.systemTemp.path}/memuno_push_${notificationId}_${DateTime.now().microsecondsSinceEpoch}.$extension';
      final File file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);
      return file.path;
    } catch (_) {
      return null;
    } finally {
      client?.close(force: true);
    }
  }

  String _resolveImageExtension(Uri uri) {
    final String path = uri.path.trim().toLowerCase();
    if (path.endsWith('.png')) {
      return 'png';
    }
    if (path.endsWith('.webp')) {
      return 'webp';
    }
    if (path.endsWith('.gif')) {
      return 'gif';
    }
    return 'jpg';
  }

  int _toNotificationIntegerId(String notificationId) {
    return notificationId.hashCode & 0x7fffffff;
  }
}
