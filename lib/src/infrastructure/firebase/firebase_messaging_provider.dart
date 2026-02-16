import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_messaging_provider.g.dart';

/// Riverpod provider for [FirebaseMessaging].
@Riverpod(keepAlive: true)
FirebaseMessaging firebaseMessaging(Ref ref) {
  // Return the singleton Firebase Messaging instance.
  return FirebaseMessaging.instance;
}
