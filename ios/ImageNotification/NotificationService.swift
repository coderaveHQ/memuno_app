import FirebaseMessaging
import Foundation
import UserNotifications
import WidgetKit

/// Notification service extension that enriches foreground notifications and widget state.
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

    applyWidgetDeltaIfPossible(userInfo: request.content.userInfo)

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

  /// Updates shared widget snapshot when push payload includes complete meme metadata.
  private func applyWidgetDeltaIfPossible(userInfo: [AnyHashable: Any]) {
    guard let delta = MemeWidgetPushDelta.parse(userInfo: userInfo),
          delta.isMemeNotification,
          delta.isCompleteForWidget,
          let appGroupId = resolveAppGroupId(),
          let defaults = UserDefaults(suiteName: appGroupId)
    else {
      return
    }

    let rawSnapshot = defaults.string(forKey: MemeWidgetSnapshotMerger.snapshotKey)
    let nextSnapshot = MemeWidgetSnapshotMerger.merge(
      rawSnapshot: rawSnapshot,
      delta: delta,
      appGroupId: appGroupId
    )
    defaults.set(nextSnapshot, forKey: MemeWidgetSnapshotMerger.snapshotKey)

    if #available(iOSApplicationExtension 14.0, *) {
      WidgetCenter.shared.reloadTimelines(ofKind: MemeWidgetSnapshotMerger.widgetKind)
    }
  }

  /// Resolves app-group identifier from extension Info.plist.
  private func resolveAppGroupId() -> String? {
    guard let value = Bundle.main.object(forInfoDictionaryKey: "MEME_WIDGET_APP_GROUP_ID") as? String else {
      return nil
    }

    let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines)
    if normalized.isEmpty {
      return nil
    }

    return normalized
  }
}

/// Parsed widget delta payload from push notification metadata.
private struct MemeWidgetPushDelta {
  /// Notification type field from payload.
  let notificationType: String

  /// Meme identifier.
  let memeId: String?

  /// Creator identifier.
  let creatorId: String?

  /// Creator display name.
  let creatorName: String?

  /// Full image storage path.
  let imagePathFull: String?

  /// Full image URL.
  let imageUrlFull: String?

  /// Aspect ratio value.
  let aspectRatio: Double?

  /// Laugh counter.
  let laughCount: Int?

  /// Current user laugh state.
  let isLaughed: Bool?

  /// Whether meme belongs to recipient.
  let isOwnMeme: Bool?

  /// Returns whether this push belongs to meme notification types.
  var isMemeNotification: Bool {
    notificationType == "meme_received" || notificationType == "meme_laughed"
  }

  /// Returns whether all fields required for local widget merge are present.
  var isCompleteForWidget: Bool {
    isMemeNotification &&
      memeId != nil &&
      creatorId != nil &&
      creatorName != nil &&
      imagePathFull != nil &&
      imageUrlFull != nil &&
      aspectRatio != nil &&
      laughCount != nil &&
      isLaughed != nil &&
      isOwnMeme != nil
  }

  /// Parses one push delta from [userInfo].
  static func parse(userInfo: [AnyHashable: Any]) -> MemeWidgetPushDelta? {
    func read(_ key: String) -> String? {
      guard let rawValue = userInfo[key] else {
        return nil
      }

      let normalized = String(describing: rawValue).trimmingCharacters(in: .whitespacesAndNewlines)
      return normalized.isEmpty ? nil : normalized
    }

    return MemeWidgetPushDelta(
      notificationType: read("notification_type") ?? "",
      memeId: read("widget_meme_id") ?? read("meme_id"),
      creatorId: read("widget_creator_id"),
      creatorName: read("widget_creator_name"),
      imagePathFull: read("widget_image_path_full"),
      imageUrlFull: read("widget_image_url_full"),
      aspectRatio: read("widget_aspect_ratio").flatMap { value in
        guard let parsed = Double(value), parsed > 0 else {
          return nil
        }
        return parsed
      },
      laughCount: read("widget_laugh_count").flatMap { value in
        guard let parsed = Int(value), parsed >= 0 else {
          return nil
        }
        return parsed
      },
      isLaughed: parseBool(read("widget_is_laughed")),
      isOwnMeme: parseBool(read("widget_is_own_meme"))
    )
  }

  /// Parses boolean strings used in push payloads.
  private static func parseBool(_ value: String?) -> Bool? {
    guard let value else {
      return nil
    }

    switch value.lowercased() {
    case "true", "1", "yes":
      return true
    case "false", "0", "no":
      return false
    default:
      return nil
    }
  }
}

/// Applies push deltas to persisted widget snapshot JSON payload.
private enum MemeWidgetSnapshotMerger {
  /// Shared defaults key used by widget extension.
  static let snapshotKey = "meme_widget_snapshot"

  /// Widget kind used for timeline refreshes.
  static let widgetKind = "MemeWidget"

  private static let defaultBackgroundHex = "#191919"
  private static let defaultForegroundHex = "#FBFBFB"

  /// Merges [delta] into existing [rawSnapshot] string.
  static func merge(
    rawSnapshot: String?,
    delta: MemeWidgetPushDelta,
    appGroupId: String
  ) -> String {
    var root = parseRoot(rawSnapshot)
    let existingItems = (root["items"] as? [[String: Any]]) ?? []
    let selectedMemeId = resolveSelectedMemeId(root: root, items: existingItems)

    let existingCurrent = existingItems.first { item in
      ((item["memeId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") == delta.memeId
    }
    let isInsertedMeme = existingCurrent == nil

    let cachedPath = resolveCachedImagePath(
      delta: delta,
      existing: existingCurrent,
      appGroupId: appGroupId
    )

    let mergedItem: [String: Any] = [
      "memeId": delta.memeId ?? "",
      "creatorId": delta.creatorId ?? "",
      "creatorName": delta.creatorName ?? "",
      "laughCount": delta.laughCount ?? 0,
      "isLaughed": delta.isLaughed ?? false,
      "isOwnMeme": delta.isOwnMeme ?? false,
      "aspectRatio": delta.aspectRatio ?? 1.0,
      "imagePath": delta.imagePathFull ?? "",
      "imageUrlFull": delta.imageUrlFull ?? "",
      "androidCachedImagePath": cachedPath ?? NSNull(),
      "backgroundHex": (existingCurrent?["backgroundHex"] as? String)?.nonEmpty ?? defaultBackgroundHex,
      "foregroundHex": (existingCurrent?["foregroundHex"] as? String)?.nonEmpty ?? defaultForegroundHex,
    ]

    var nextItems: [[String: Any]] = [mergedItem]
    for item in existingItems {
      if nextItems.count >= 5 {
        break
      }
      let itemId = ((item["memeId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
      if itemId.isEmpty || itemId == delta.memeId {
        continue
      }
      nextItems.append(item)
    }

    root["status"] = "ready"
    root["items"] = nextItems
    root["selectedIndex"] = isInsertedMeme
      ? 0
      : resolveSelectedIndex(items: nextItems, selectedMemeId: selectedMemeId)
    let currentPendingLaughMemeId = (root["pendingLaughMemeId"] as? String)?.nonEmpty
    if currentPendingLaughMemeId == nil || currentPendingLaughMemeId == delta.memeId {
      root["pendingLaughMemeId"] = NSNull()
    } else {
      root["pendingLaughMemeId"] = currentPendingLaughMemeId
    }
    root["updatedAtEpochMs"] = Int(Date().timeIntervalSince1970 * 1000)
    root["emptyText"] = (root["emptyText"] as? String)?.nonEmpty ?? "No memes, yet."
    root["signedOutText"] = (root["signedOutText"] as? String)?.nonEmpty ?? "Sign in to display memes."
    root["laughActionText"] = (root["laughActionText"] as? String)?.nonEmpty ?? "Laugh"
    root["unlaughActionText"] = (root["unlaughActionText"] as? String)?.nonEmpty ?? "Unlaugh"
    root["ownerActionText"] = (root["ownerActionText"] as? String)?.nonEmpty ?? "Owner"

    guard JSONSerialization.isValidJSONObject(root),
          let data = try? JSONSerialization.data(withJSONObject: root),
          let json = String(data: data, encoding: .utf8)
    else {
      return rawSnapshot ?? ""
    }

    return json
  }

  /// Parses one raw snapshot JSON string into dictionary representation.
  private static func parseRoot(_ rawSnapshot: String?) -> [String: Any] {
    guard let rawSnapshot,
          !rawSnapshot.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          let data = rawSnapshot.data(using: .utf8),
          let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    else {
      return [:]
    }

    return json
  }

  /// Resolves currently selected meme identifier from [root] and [items].
  private static func resolveSelectedMemeId(root: [String: Any], items: [[String: Any]]) -> String? {
    guard !items.isEmpty else {
      return nil
    }

    let rawIndex = root["selectedIndex"] as? Int ?? 0
    let safeIndex = max(0, min(rawIndex, items.count - 1))
    let id = (items[safeIndex]["memeId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    if let id, !id.isEmpty {
      return id
    }

    return nil
  }

  /// Resolves selected index for [items] while preserving [selectedMemeId] when possible.
  private static func resolveSelectedIndex(items: [[String: Any]], selectedMemeId: String?) -> Int {
    guard !items.isEmpty, let selectedMemeId, !selectedMemeId.isEmpty else {
      return 0
    }

    if let index = items.firstIndex(where: { item in
      ((item["memeId"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "") == selectedMemeId
    }) {
      return index
    }

    return 0
  }

  /// Resolves one local cached image path for [delta].
  private static func resolveCachedImagePath(
    delta: MemeWidgetPushDelta,
    existing: [String: Any]?,
    appGroupId: String
  ) -> String? {
    if let existing,
       let existingUrl = (existing["imageUrlFull"] as? String)?.nonEmpty,
       existingUrl == delta.imageUrlFull,
       let existingPath = (existing["androidCachedImagePath"] as? String)?.nonEmpty,
       fileExists(atPath: existingPath) {
      return normalizeFilePath(existingPath)
    }

    guard let memeId = delta.memeId, !memeId.isEmpty,
          let imageUrl = delta.imageUrlFull, !imageUrl.isEmpty
    else {
      return nil
    }

    return downloadAndCacheImage(
      memeId: memeId,
      imageUrl: imageUrl,
      appGroupId: appGroupId
    )
  }

  /// Downloads and stores one image in the shared app-group container.
  private static func downloadAndCacheImage(
    memeId: String,
    imageUrl: String,
    appGroupId: String
  ) -> String? {
    guard let bytes = downloadImageData(from: imageUrl),
          !bytes.isEmpty,
          let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
          )
    else {
      return nil
    }

    let directoryURL = containerURL.appendingPathComponent("home_widget", isDirectory: true)
    let fileURL = directoryURL.appendingPathComponent("meme_widget_\(memeId).bin", isDirectory: false)

    do {
      try FileManager.default.createDirectory(
        at: directoryURL,
        withIntermediateDirectories: true
      )
      try bytes.write(to: fileURL, options: [.atomic])
      return fileURL.path
    } catch {
      return nil
    }
  }

  /// Downloads image bytes with bounded request and wait time.
  private static func downloadImageData(from rawUrl: String) -> Data? {
    guard let url = URL(string: rawUrl) else {
      return nil
    }

    var request = URLRequest(url: url)
    request.timeoutInterval = 8
    request.cachePolicy = .reloadIgnoringLocalCacheData

    let semaphore = DispatchSemaphore(value: 0)
    var downloadedData: Data?

    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForRequest = 8
    configuration.timeoutIntervalForResource = 9
    let session = URLSession(configuration: configuration)

    let task = session.dataTask(with: request) { data, response, _ in
      defer { semaphore.signal() }
      guard let httpResponse = response as? HTTPURLResponse,
            (200 ... 299).contains(httpResponse.statusCode),
            let data,
            !data.isEmpty
      else {
        return
      }
      downloadedData = data
    }
    task.resume()

    let waitResult = semaphore.wait(timeout: .now() + 9)
    if waitResult == .timedOut {
      task.cancel()
      session.invalidateAndCancel()
      return nil
    }

    session.finishTasksAndInvalidate()
    return downloadedData
  }

  /// Returns whether one local file path exists.
  private static func fileExists(atPath rawPath: String) -> Bool {
    let normalizedPath = normalizeFilePath(rawPath)
    if normalizedPath.isEmpty {
      return false
    }
    return FileManager.default.fileExists(atPath: normalizedPath)
  }

  /// Normalizes file URL strings into local file-system paths.
  private static func normalizeFilePath(_ rawPath: String) -> String {
    let trimmed = rawPath.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      return ""
    }

    if let url = URL(string: trimmed),
       url.scheme?.lowercased() == "file" {
      return url.path
    }

    return trimmed
  }
}

private extension String {
  /// Returns trimmed value when non-empty.
  var nonEmpty: String? {
    let normalized = trimmingCharacters(in: .whitespacesAndNewlines)
    return normalized.isEmpty ? nil : normalized
  }
}
