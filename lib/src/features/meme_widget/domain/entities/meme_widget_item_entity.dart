/// Immutable widget payload item for one meme entry.
final class MemeWidgetItemEntity {
  /// Creates one widget item.
  const MemeWidgetItemEntity({
    required this.memeId,
    required this.creatorId,
    required this.creatorName,
    required this.laughCount,
    required this.isLaughed,
    required this.isOwnMeme,
    required this.aspectRatio,
    required this.imagePath,
    required this.imageUrlFull,
    required this.androidCachedImagePath,
    required this.backgroundHex,
    required this.foregroundHex,
  });

  /// Meme identifier.
  final String memeId;

  /// Creator user identifier.
  final String creatorId;

  /// Creator display name.
  final String creatorName;

  /// Total laugh count.
  final int laughCount;

  /// Whether the current user laughed at this meme.
  final bool isLaughed;

  /// Whether this meme belongs to the current user.
  final bool isOwnMeme;

  /// Persisted aspect ratio from backend.
  final double aspectRatio;

  /// Storage path of the full-resolution meme image.
  final String imagePath;

  /// Signed full-resolution image URL used by widgets.
  final String imageUrlFull;

  /// Locally cached Android file path for Glance image rendering.
  final String? androidCachedImagePath;

  /// Solid background color in `#RRGGBB` format.
  final String backgroundHex;

  /// Foreground color in `#RRGGBB` format.
  final String foregroundHex;

  /// Creates one entity from JSON.
  factory MemeWidgetItemEntity.fromJson(Map<String, Object?> json) {
    return MemeWidgetItemEntity(
      memeId: json['memeId']! as String,
      creatorId: json['creatorId']! as String,
      creatorName: json['creatorName']! as String,
      laughCount: json['laughCount']! as int,
      isLaughed: json['isLaughed']! as bool,
      isOwnMeme: json['isOwnMeme']! as bool,
      aspectRatio: (json['aspectRatio']! as num).toDouble(),
      imagePath: json['imagePath']! as String,
      imageUrlFull: json['imageUrlFull']! as String,
      androidCachedImagePath: json['androidCachedImagePath'] as String?,
      backgroundHex: json['backgroundHex']! as String,
      foregroundHex: json['foregroundHex']! as String,
    );
  }

  /// Converts this entity to JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'memeId': memeId,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'laughCount': laughCount,
      'isLaughed': isLaughed,
      'isOwnMeme': isOwnMeme,
      'aspectRatio': aspectRatio,
      'imagePath': imagePath,
      'imageUrlFull': imageUrlFull,
      'androidCachedImagePath': androidCachedImagePath,
      'backgroundHex': backgroundHex,
      'foregroundHex': foregroundHex,
    };
  }

  /// Returns a copy with selectively replaced fields.
  MemeWidgetItemEntity copyWith({
    String? memeId,
    String? creatorId,
    String? creatorName,
    int? laughCount,
    bool? isLaughed,
    bool? isOwnMeme,
    double? aspectRatio,
    String? imagePath,
    String? imageUrlFull,
    String? androidCachedImagePath,
    bool clearAndroidCachedImagePath = false,
    String? backgroundHex,
    String? foregroundHex,
  }) {
    return MemeWidgetItemEntity(
      memeId: memeId ?? this.memeId,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      laughCount: laughCount ?? this.laughCount,
      isLaughed: isLaughed ?? this.isLaughed,
      isOwnMeme: isOwnMeme ?? this.isOwnMeme,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      imagePath: imagePath ?? this.imagePath,
      imageUrlFull: imageUrlFull ?? this.imageUrlFull,
      androidCachedImagePath: clearAndroidCachedImagePath
          ? null
          : (androidCachedImagePath ?? this.androidCachedImagePath),
      backgroundHex: backgroundHex ?? this.backgroundHex,
      foregroundHex: foregroundHex ?? this.foregroundHex,
    );
  }
}
