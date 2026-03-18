import FirebaseMessaging
import Foundation
import UserNotifications

/// Notification service extension that enriches incoming notifications.
final class NotificationService: UNNotificationServiceExtension {
  private var contentHandler: ((UNNotificationContent) -> Void)?
  private var bestAttemptContent: UNMutableNotificationContent?

  /// Handles incoming push notifications before they are presented.
  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    self.contentHandler = contentHandler
    bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent

    guard let bestAttemptContent else {
      contentHandler(request.content)
      return
    }

    Messaging.serviceExtension().populateNotificationContent(
      bestAttemptContent,
      withContentHandler: contentHandler
    )
  }

  /// Delivers best attempt content before extension timeout.
  override func serviceExtensionTimeWillExpire() {
    guard
      let contentHandler,
      let bestAttemptContent
    else {
      return
    }

    contentHandler(bestAttemptContent)
  }
}
