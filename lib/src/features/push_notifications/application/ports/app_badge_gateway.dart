/// Port for app-icon badge updates.
abstract interface class AppBadgeGateway {
  /// Sets the app icon badge count.
  Future<void> setBadgeCount(int count);

  /// Clears the app icon badge.
  Future<void> clearBadge();
}
