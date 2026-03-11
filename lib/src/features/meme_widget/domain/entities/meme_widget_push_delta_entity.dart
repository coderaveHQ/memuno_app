/// Parsed push delta payload for fast local widget updates.
final class MemeWidgetPushDeltaEntity {
  /// Creates one push-delta model.
  const MemeWidgetPushDeltaEntity({
    required this.notificationType,
    required this.memeId,
    required this.creatorId,
    required this.creatorName,
    required this.imagePathFull,
    required this.imageUrlFull,
    required this.aspectRatio,
    required this.laughCount,
    required this.isLaughed,
    required this.isOwnMeme,
  });

  /// Notification type value from push payload.
  final String notificationType;

  /// Meme identifier for the updated meme.
  final String? memeId;

  /// Creator user identifier.
  final String? creatorId;

  /// Creator display name.
  final String? creatorName;

  /// Full-resolution image storage path.
  final String? imagePathFull;

  /// Full-resolution signed image URL.
  final String? imageUrlFull;

  /// Meme aspect ratio.
  final double? aspectRatio;

  /// Meme laugh counter.
  final int? laughCount;

  /// Whether the recipient has laughed on this meme.
  final bool? isLaughed;

  /// Whether the meme belongs to the recipient.
  final bool? isOwnMeme;

  /// Returns whether this push is relevant for meme widgets.
  bool get isMemeNotification {
    return notificationType == 'meme_received' ||
        notificationType == 'meme_laughed';
  }

  /// Returns whether all fields required for local widget upsert are present.
  bool get isCompleteForWidget {
    return isMemeNotification &&
        memeId != null &&
        creatorId != null &&
        creatorName != null &&
        imagePathFull != null &&
        imageUrlFull != null &&
        aspectRatio != null &&
        laughCount != null &&
        isLaughed != null &&
        isOwnMeme != null;
  }

  /// Parses one push delta from FCM data payload [data].
  factory MemeWidgetPushDeltaEntity.fromPushData(Map<String, String> data) {
    String? read(String key) {
      final String? value = data[key]?.trim();
      if (value == null || value.isEmpty) {
        return null;
      }
      return value;
    }

    return MemeWidgetPushDeltaEntity(
      notificationType: read('notification_type') ?? '',
      memeId: read('widget_meme_id') ?? read('meme_id'),
      creatorId: read('widget_creator_id'),
      creatorName: read('widget_creator_name'),
      imagePathFull: read('widget_image_path_full'),
      imageUrlFull: read('widget_image_url_full'),
      aspectRatio: _parsePositiveDouble(read('widget_aspect_ratio')),
      laughCount: _parseNonNegativeInt(read('widget_laugh_count')),
      isLaughed: _parseBool(read('widget_is_laughed')),
      isOwnMeme: _parseBool(read('widget_is_own_meme')),
    );
  }

  static double? _parsePositiveDouble(String? rawValue) {
    if (rawValue == null) {
      return null;
    }

    final double? parsed = double.tryParse(rawValue);
    if (parsed == null || parsed <= 0) {
      return null;
    }

    return parsed;
  }

  static int? _parseNonNegativeInt(String? rawValue) {
    if (rawValue == null) {
      return null;
    }

    final int? parsed = int.tryParse(rawValue);
    if (parsed == null || parsed < 0) {
      return null;
    }

    return parsed;
  }

  static bool? _parseBool(String? rawValue) {
    if (rawValue == null) {
      return null;
    }

    final String normalized = rawValue.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
      return true;
    }

    if (normalized == 'false' || normalized == '0' || normalized == 'no') {
      return false;
    }

    return null;
  }
}
