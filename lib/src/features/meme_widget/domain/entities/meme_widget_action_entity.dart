/// Action types emitted by native widget interactions.
enum MemeWidgetActionType {
  /// Opens the app default route.
  openApp,

  /// Opens one meme details page.
  openMeme,

  /// Toggles laugh state for one meme.
  laugh,

  /// Moves widget pager to previous meme.
  previous,

  /// Moves widget pager to next meme.
  next,

  /// Unknown action.
  unknown,
}

/// Domain model for one widget action URI payload.
final class MemeWidgetActionEntity {
  /// Creates one action instance.
  const MemeWidgetActionEntity({
    required this.type,
    required this.rawUri,
    this.memeId,
  });

  /// Parsed action type.
  final MemeWidgetActionType type;

  /// Original action URI.
  final Uri rawUri;

  /// Optional meme identifier attached to the action.
  final String? memeId;

  /// Parses one action entity from [uri].
  factory MemeWidgetActionEntity.fromUri(Uri uri) {
    final String? rawType = _readFirst(uri, <String>['type', 'action']);
    final String? memeId =
        _readFirst(uri, <String>['memeId', 'meme_id']) ??
        _extractMemeIdFromPath(uri);

    final MemeWidgetActionType type = switch (rawType) {
      'open_app' || 'openApp' => MemeWidgetActionType.openApp,
      'open_meme' || 'openMeme' => MemeWidgetActionType.openMeme,
      'laugh' || 'toggle_laugh' => MemeWidgetActionType.laugh,
      'prev' || 'previous' => MemeWidgetActionType.previous,
      'next' => MemeWidgetActionType.next,
      _ => _inferTypeFromPath(uri.path),
    };

    return MemeWidgetActionEntity(type: type, rawUri: uri, memeId: memeId);
  }

  /// Returns this action encoded as URI.
  Uri toUri() {
    return rawUri;
  }

  static MemeWidgetActionType _inferTypeFromPath(String path) {
    final String normalized = path.trim().toLowerCase();
    if (normalized.startsWith('/memes/')) {
      return MemeWidgetActionType.openMeme;
    }
    if (normalized.contains('open')) {
      return MemeWidgetActionType.openMeme;
    }
    if (normalized.contains('laugh')) {
      return MemeWidgetActionType.laugh;
    }
    if (normalized.contains('next')) {
      return MemeWidgetActionType.next;
    }
    if (normalized.contains('prev')) {
      return MemeWidgetActionType.previous;
    }
    if (normalized.isEmpty || normalized == '/') {
      return MemeWidgetActionType.openApp;
    }
    return MemeWidgetActionType.unknown;
  }

  static String? _readFirst(Uri uri, List<String> keys) {
    for (final String key in keys) {
      final String? value = uri.queryParameters[key]?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  static String? _extractMemeIdFromPath(Uri uri) {
    if (uri.pathSegments.length >= 2 && uri.pathSegments.first == 'memes') {
      final String value = uri.pathSegments[1].trim();
      if (value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }
}
