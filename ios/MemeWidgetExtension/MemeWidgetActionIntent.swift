import AppIntents
import Foundation
import home_widget

/// Generic widget action intent that forwards URIs to Flutter background callbacks.
@available(iOS 17, *)
struct MemeWidgetActionIntent: AppIntent {
  /// Intent title shown by the system.
  static var title: LocalizedStringResource = "Meme Widget Action"

  /// Target URI interpreted by Flutter `MemeWidgetActionEntity`.
  @Parameter(title: "Widget URI")
  var url: URL?

  /// App-group id used by `HomeWidgetBackgroundWorker`.
  @Parameter(title: "App Group")
  var appGroup: String?

  /// Creates an empty intent instance.
  init() {}

  /// Creates a preconfigured intent for one URI/action.
  init(url: URL?, appGroup: String?) {
    self.url = url
    self.appGroup = appGroup
  }

  /// Executes the action by calling into `home_widget` background worker.
  func perform() async throws -> some IntentResult {
    guard let appGroup else {
      return .result()
    }

    await HomeWidgetBackgroundWorker.run(url: url, appGroup: appGroup)
    return .result()
  }
}

/// Enables running this intent even when the host app is suspended.
@available(iOS 17, *)
@available(iOSApplicationExtension, unavailable)
extension MemeWidgetActionIntent: ForegroundContinuableIntent {}
