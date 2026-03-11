import SwiftUI
import UIKit
import WidgetKit

/// Configuration constants used by the meme widget extension.
private enum MemeWidgetConfiguration {
  /// Shared `UserDefaults` key containing serialized widget snapshot JSON.
  static let snapshotKey = "meme_widget_snapshot"

  /// Widget kind used by WidgetKit and Flutter `HomeWidget.updateWidget`.
  static let kind = "MemeWidget"

  /// App-group identifier injected via build settings.
  static var appGroupId: String? {
    if let value = Bundle.main.object(forInfoDictionaryKey: "MEME_WIDGET_APP_GROUP_ID") as? String,
       !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return value
    }
    return nil
  }
}

/// Timeline provider that loads the latest meme-widget snapshot from shared defaults.
private struct MemeWidgetProvider: TimelineProvider {
  /// Placeholder entry used by WidgetKit in loading states.
  func placeholder(in context: Context) -> MemeWidgetEntry {
    MemeWidgetEntry(date: Date(), snapshot: MemeWidgetSnapshot.fallbackSignedOut)
  }

  /// Snapshot entry used by gallery previews and transient widget states.
  func getSnapshot(in context: Context, completion: @escaping (MemeWidgetEntry) -> Void) {
    completion(MemeWidgetEntry(date: Date(), snapshot: loadSnapshot()))
  }

  /// Produces a single-entry timeline; Flutter triggers updates via HomeWidget.
  func getTimeline(in context: Context, completion: @escaping (Timeline<MemeWidgetEntry>) -> Void) {
    let entry = MemeWidgetEntry(date: Date(), snapshot: loadSnapshot())
    completion(Timeline(entries: [entry], policy: .atEnd))
  }

  /// Loads and decodes the current persisted snapshot.
  private func loadSnapshot() -> MemeWidgetSnapshot {
    let defaults = UserDefaults(suiteName: MemeWidgetConfiguration.appGroupId)
    let raw = defaults?.string(forKey: MemeWidgetConfiguration.snapshotKey)
    return MemeWidgetSnapshot.decode(fromRawJson: raw)
  }
}

/// Timeline entry carrying parsed snapshot payload data.
private struct MemeWidgetEntry: TimelineEntry {
  /// Entry timestamp.
  let date: Date

  /// Parsed snapshot model rendered by the widget.
  let snapshot: MemeWidgetSnapshot
}

/// Root view for the meme widget entry.
private struct MemeWidgetEntryView: View {
  /// Entry payload to render.
  let entry: MemeWidgetEntry

  /// Resolved current snapshot.
  private var snapshot: MemeWidgetSnapshot {
    entry.snapshot
  }

  var body: some View {
    switch snapshot.status {
    case .signedOut:
      placeholderView(text: snapshot.signedOutText)
        .widgetURL(MemeWidgetUris.openApp)
    case .empty:
      placeholderView(text: snapshot.emptyText)
        .widgetURL(MemeWidgetUris.openApp)
    case .ready:
      if let item = snapshot.selectedItem {
        readyView(item: item)
      } else {
        placeholderView(text: snapshot.emptyText)
          .widgetURL(MemeWidgetUris.openApp)
      }
    }
  }

  /// Placeholder UI used for signed-out and empty states.
  private func placeholderView(text: String) -> some View {
    ZStack {
      MemeWidgetPalette.gray900
      Text(text)
        .font(.subheadline)
        .fontWeight(.medium)
        .multilineTextAlignment(.center)
        .foregroundStyle(MemeWidgetPalette.gray100)
        .padding(12)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .containerBackground(for: .widget) {
      MemeWidgetPalette.gray900
    }
  }

  /// Ready-state UI showing one meme image with overlaid controls and badges.
  private func readyView(item: MemeWidgetItem) -> some View {
    let background = MemeWidgetPalette.color(fromHex: item.backgroundHex, fallback: MemeWidgetPalette.gray900)
    let foreground = MemeWidgetPalette.color(fromHex: item.foregroundHex, fallback: MemeWidgetPalette.gray100)
    let isLaughPending = snapshot.pendingLaughMemeId == item.memeId

    return ZStack {
      background

      Link(destination: MemeWidgetUris.openMeme(memeId: item.memeId)) {
        if let cachedImage = MemeWidgetImageLoader.loadImage(fromPath: item.androidCachedImagePath) {
          Image(uiImage: cachedImage)
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      }
      .buttonStyle(.plain)

      VStack(spacing: 0) {
        HStack(spacing: 6) {
          Badge(
            text: item.creatorName,
            background: .black.opacity(0.35),
            foreground: foreground
          )
          Spacer(minLength: 0)
          laughChip(
            item: item,
            isPending: isLaughPending,
            foreground: foreground
          )
        }
        Spacer(minLength: 0)
      }
      .padding(10)

      if #available(iOSApplicationExtension 17.0, *) {
        HStack {
          navigationButton(
            intent: MemeWidgetActionIntent(
              url: MemeWidgetUris.previous,
              appGroup: MemeWidgetConfiguration.appGroupId
            ),
            symbol: "<",
            foreground: foreground
          )
          Spacer(minLength: 0)
          navigationButton(
            intent: MemeWidgetActionIntent(
              url: MemeWidgetUris.next,
              appGroup: MemeWidgetConfiguration.appGroupId
            ),
            symbol: ">",
            foreground: foreground
          )
        }
        .padding(.horizontal, 8)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .containerBackground(for: .widget) {
      background
    }
  }

  /// Creates a top-row laugh chip that matches app feed interaction styling.
  @ViewBuilder
  private func laughChip(
    item: MemeWidgetItem,
    isPending: Bool,
    foreground _: Color
  ) -> some View {
    let chipBackground = item.isLaughed
      ? MemeWidgetPalette.laughSelectedBackground
      : MemeWidgetPalette.laughUnselectedBackground
    let chipForeground = item.isLaughed
      ? MemeWidgetPalette.laughSelectedForeground
      : MemeWidgetPalette.laughUnselectedForeground
    let chipText = "😂 \(item.laughCount)"

    if #available(iOSApplicationExtension 17.0, *), !item.isOwnMeme {
      Button(intent: MemeWidgetActionIntent(
        url: MemeWidgetUris.laugh(memeId: item.memeId),
        appGroup: MemeWidgetConfiguration.appGroupId
      )) {
        Text(chipText)
          .font(.caption)
          .fontWeight(.semibold)
          .lineLimit(1)
          .padding(.horizontal, 10)
          .padding(.vertical, 6)
          .background(chipBackground)
          .clipShape(Capsule())
      }
      .buttonStyle(.plain)
      .foregroundStyle(chipForeground)
      .disabled(isPending)
      .opacity(isPending ? 0.6 : 1)
    } else {
      Badge(
        text: chipText,
        background: chipBackground,
        foreground: chipForeground
      )
    }
  }

  /// Creates one centered navigation action button.
  @ViewBuilder
  private func navigationButton(
    intent: MemeWidgetActionIntent,
    symbol: String,
    foreground: Color
  ) -> some View {
    Button(intent: intent) {
      Text(symbol)
        .font(.caption)
        .fontWeight(.semibold)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(minWidth: 46, minHeight: 46)
        .background(.black.opacity(0.35))
        .clipShape(Capsule())
    }
    .buttonStyle(.plain)
    .foregroundStyle(foreground)
  }
}

/// Small text badge used for overlaid metadata chips.
private struct Badge: View {
  /// Badge text.
  let text: String

  /// Badge background color.
  let background: Color

  /// Badge foreground color.
  let foreground: Color

  var body: some View {
    Text(text)
      .font(.caption2)
      .fontWeight(.semibold)
      .lineLimit(1)
      .padding(.horizontal, 7)
      .padding(.vertical, 4)
      .foregroundStyle(foreground)
      .background(background)
      .clipShape(Capsule())
  }
}

/// Widget definition exposed to WidgetKit.
struct MemeWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: MemeWidgetConfiguration.kind, provider: MemeWidgetProvider()) { entry in
      MemeWidgetEntryView(entry: entry)
    }
    .contentMarginsDisabled()
  }
}

/// Widget bundle entry point.
@main
struct MemeWidgetBundle: WidgetBundle {
  var body: some Widget {
    MemeWidget()
  }
}

/// Snapshot status values serialized by Flutter.
private enum MemeWidgetStatus: String, Decodable {
  /// No authenticated session exists.
  case signedOut

  /// Session exists but feed is empty.
  case empty

  /// Widget has renderable meme entries.
  case ready
}

/// Parsed snapshot payload model.
private struct MemeWidgetSnapshot: Decodable {
  /// Current status for placeholder/ready rendering.
  let status: MemeWidgetStatus

  /// Latest meme items payload.
  let items: [MemeWidgetItem]

  /// Selected index used for pager rendering.
  let selectedIndex: Int

  /// Meme id that currently has a pending laugh toggle.
  let pendingLaughMemeId: String?

  /// Localized empty-state text persisted by Flutter.
  let emptyText: String

  /// Localized signed-out text persisted by Flutter.
  let signedOutText: String

  /// Localized laugh action text persisted by Flutter.
  let laughActionText: String

  /// Localized unlaugh action text persisted by Flutter.
  let unlaughActionText: String

  /// Localized owner label persisted by Flutter.
  let ownerActionText: String

  /// Creates one snapshot model from resolved values.
  init(
    status: MemeWidgetStatus,
    items: [MemeWidgetItem],
    selectedIndex: Int,
    pendingLaughMemeId: String?,
    emptyText: String,
    signedOutText: String,
    laughActionText: String,
    unlaughActionText: String,
    ownerActionText: String
  ) {
    self.status = status
    self.items = items
    self.selectedIndex = selectedIndex
    self.pendingLaughMemeId = pendingLaughMemeId
    self.emptyText = emptyText
    self.signedOutText = signedOutText
    self.laughActionText = laughActionText
    self.unlaughActionText = unlaughActionText
    self.ownerActionText = ownerActionText
  }

  /// Fallback signed-out snapshot used when no shared state exists.
  static let fallbackSignedOut = MemeWidgetSnapshot(
    status: .signedOut,
    items: [],
    selectedIndex: 0,
    pendingLaughMemeId: nil,
    emptyText: "No memes, yet.",
    signedOutText: "Sign in to display memes.",
    laughActionText: "Laugh",
    unlaughActionText: "Unlaugh",
    ownerActionText: "Owner"
  )

  /// Coding keys for persisted snapshot JSON payload.
  private enum CodingKeys: String, CodingKey {
    case status
    case items
    case selectedIndex
    case pendingLaughMemeId
    case emptyText
    case signedOutText
    case laughActionText
    case unlaughActionText
    case ownerActionText
  }

  /// Decodes snapshots with compatibility fallbacks for newly added fields.
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    status = try container.decodeIfPresent(MemeWidgetStatus.self, forKey: .status) ?? .empty
    items = try container.decodeIfPresent([MemeWidgetItem].self, forKey: .items) ?? []
    selectedIndex = try container.decodeIfPresent(Int.self, forKey: .selectedIndex) ?? 0
    pendingLaughMemeId = try container
      .decodeIfPresent(String.self, forKey: .pendingLaughMemeId)?
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .nilIfEmpty
    emptyText = try container.decodeIfPresent(String.self, forKey: .emptyText) ?? "No memes, yet."
    signedOutText = try container.decodeIfPresent(String.self, forKey: .signedOutText) ?? "Sign in to display memes."
    laughActionText = try container.decodeIfPresent(String.self, forKey: .laughActionText) ?? "Laugh"
    unlaughActionText = try container.decodeIfPresent(String.self, forKey: .unlaughActionText) ?? "Unlaugh"
    ownerActionText = try container.decodeIfPresent(String.self, forKey: .ownerActionText) ?? "Owner"
  }

  /// Returns currently selected item if available.
  var selectedItem: MemeWidgetItem? {
    guard !items.isEmpty else { return nil }
    let normalized = max(0, min(selectedIndex, items.count - 1))
    return items[normalized]
  }

  /// Decodes one JSON snapshot string produced by Flutter.
  static func decode(fromRawJson raw: String?) -> MemeWidgetSnapshot {
    guard let raw, !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      return fallbackSignedOut
    }

    do {
      let data = Data(raw.utf8)
      return try JSONDecoder().decode(MemeWidgetSnapshot.self, from: data)
    } catch {
      return fallbackSignedOut
    }
  }
}

/// Parsed meme-item payload model.
private struct MemeWidgetItem: Decodable {
  /// Meme identifier.
  let memeId: String

  /// Creator display name.
  let creatorName: String

  /// Current laugh counter.
  let laughCount: Int

  /// Whether current user has laughed.
  let isLaughed: Bool

  /// Whether current user owns this meme.
  let isOwnMeme: Bool

  /// Signed full-resolution image URL.
  let imageUrlFull: String

  /// Locally cached widget image file path.
  let androidCachedImagePath: String?

  /// Background color in `#RRGGBB`.
  let backgroundHex: String

  /// Foreground color in `#RRGGBB`.
  let foregroundHex: String
}

/// Utility for widget action URI generation.
private enum MemeWidgetUris {
  /// Opens app root.
  static let openApp = URL(string: "memuno://meme-widget?action=open_app")!

  /// Moves pager to previous item.
  static let previous = URL(string: "memuno://meme-widget?action=prev")!

  /// Moves pager to next item.
  static let next = URL(string: "memuno://meme-widget?action=next")!

  /// Opens one meme details route.
  static func openMeme(memeId: String) -> URL {
    URL(string: "memuno://meme-widget?action=open_meme&memeId=\(memeId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? memeId)")!
  }

  /// Toggles laugh for one meme.
  static func laugh(memeId: String) -> URL {
    URL(string: "memuno://meme-widget?action=laugh&memeId=\(memeId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? memeId)")!
  }
}

/// Shared widget color palette and color parsing helpers.
private enum MemeWidgetPalette {
  /// App design-system `MColors.gray900`.
  static let gray900 = Color(red: 0x19 / 255.0, green: 0x19 / 255.0, blue: 0x19 / 255.0)

  /// App design-system `MColors.gray100`.
  static let gray100 = Color(red: 0xFB / 255.0, green: 0xFB / 255.0, blue: 0xFB / 255.0)

  /// Feed-like laugh chip selected background.
  static let laughSelectedBackground = Color(red: 0xF6 / 255.0, green: 0xE0 / 255.0, blue: 0x5E / 255.0).opacity(0.1)

  /// Feed-like laugh chip selected foreground.
  static let laughSelectedForeground = Color(red: 0xF6 / 255.0, green: 0xE0 / 255.0, blue: 0x5E / 255.0)

  /// Feed-like laugh chip default background.
  static let laughUnselectedBackground = gray100

  /// Feed-like laugh chip default foreground.
  static let laughUnselectedForeground = gray900

  /// Parses hexadecimal color values and falls back when invalid.
  static func color(fromHex hex: String, fallback: Color) -> Color {
    var normalized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if normalized.hasPrefix("#") {
      normalized.removeFirst()
    }

    guard normalized.count == 6, let value = Int(normalized, radix: 16) else {
      return fallback
    }

    let red = Double((value >> 16) & 0xFF) / 255.0
    let green = Double((value >> 8) & 0xFF) / 255.0
    let blue = Double(value & 0xFF) / 255.0
    return Color(red: red, green: green, blue: blue)
  }
}

/// Resolves local file-backed widget images from shared snapshot payloads.
private enum MemeWidgetImageLoader {
  /// Loads one image from [rawPath] when available.
  static func loadImage(fromPath rawPath: String?) -> UIImage? {
    guard let rawPath else {
      return nil
    }

    let trimmed = rawPath.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      return nil
    }

    if let url = URL(string: trimmed),
       url.scheme?.lowercased() == "file",
       !url.path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
      return UIImage(contentsOfFile: url.path)
    }

    return UIImage(contentsOfFile: trimmed)
  }
}

private extension String {
  /// Returns nil when the string is empty.
  var nilIfEmpty: String? {
    isEmpty ? nil : self
  }
}
