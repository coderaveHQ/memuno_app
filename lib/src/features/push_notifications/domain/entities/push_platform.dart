/// Supported push token platforms.
enum PushPlatform {
  /// Apple Push Notification Service via FCM.
  ios,

  /// Android FCM device token.
  android;

  /// Database enum value.
  String get dbValue {
    return switch (this) {
      PushPlatform.ios => 'ios',
      PushPlatform.android => 'android',
    };
  }
}
