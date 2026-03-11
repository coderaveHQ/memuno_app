import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_item_entity.dart';

/// Status of persisted widget data.
enum MemeWidgetSnapshotStatus {
  /// No authenticated user exists for widget rendering.
  signedOut,

  /// User is authenticated but no memes are available.
  empty,

  /// Widget has renderable meme data.
  ready,
}

/// Full persisted widget snapshot shared with native widgets.
final class MemeWidgetSnapshotEntity {
  /// Creates a widget snapshot.
  const MemeWidgetSnapshotEntity({
    required this.status,
    required this.items,
    required this.selectedIndex,
    required this.updatedAtEpochMs,
    required this.pendingLaughMemeId,
    required this.emptyText,
    required this.signedOutText,
    required this.laughActionText,
    required this.unlaughActionText,
    required this.ownerActionText,
  });

  /// Current widget status.
  final MemeWidgetSnapshotStatus status;

  /// Meme items rendered by the widget.
  final List<MemeWidgetItemEntity> items;

  /// Selected item index for pager-based widgets.
  final int selectedIndex;

  /// Last update timestamp in milliseconds since epoch.
  final int updatedAtEpochMs;

  /// Meme identifier currently waiting for laugh-toggle persistence.
  final String? pendingLaughMemeId;

  /// Localized empty-state text.
  final String emptyText;

  /// Localized signed-out text.
  final String signedOutText;

  /// Localized laugh action label.
  final String laughActionText;

  /// Localized unlaugh action label.
  final String unlaughActionText;

  /// Localized owner label for own memes.
  final String ownerActionText;

  /// Returns a safe selected index for current items.
  int get safeSelectedIndex {
    if (items.isEmpty) {
      return 0;
    }

    if (selectedIndex < 0) {
      return 0;
    }

    if (selectedIndex >= items.length) {
      return items.length - 1;
    }

    return selectedIndex;
  }

  /// Creates one snapshot from JSON.
  factory MemeWidgetSnapshotEntity.fromJson(Map<String, Object?> json) {
    final List<dynamic> rawItems =
        (json['items'] as List<dynamic>? ?? const <dynamic>[]);

    return MemeWidgetSnapshotEntity(
      status: _parseStatus(json['status'] as String? ?? 'empty'),
      items: rawItems
          .whereType<Map<dynamic, dynamic>>()
          .map(
            (Map<dynamic, dynamic> value) =>
                MemeWidgetItemEntity.fromJson(Map<String, Object?>.from(value)),
          )
          .toList(growable: false),
      selectedIndex: json['selectedIndex'] is int
          ? json['selectedIndex']! as int
          : 0,
      updatedAtEpochMs: json['updatedAtEpochMs'] is int
          ? json['updatedAtEpochMs']! as int
          : DateTime.now().millisecondsSinceEpoch,
      pendingLaughMemeId: json['pendingLaughMemeId'] is String
          ? (json['pendingLaughMemeId']! as String).trim().isEmpty
                ? null
                : (json['pendingLaughMemeId']! as String).trim()
          : null,
      emptyText: (json['emptyText'] as String?) ?? '',
      signedOutText: (json['signedOutText'] as String?) ?? '',
      laughActionText: (json['laughActionText'] as String?) ?? '',
      unlaughActionText: (json['unlaughActionText'] as String?) ?? '',
      ownerActionText: (json['ownerActionText'] as String?) ?? '',
    );
  }

  /// Converts this snapshot to JSON.
  Map<String, Object?> toJson() {
    return <String, Object?>{
      'status': status.name,
      'items': items.map((MemeWidgetItemEntity item) => item.toJson()).toList(),
      'selectedIndex': safeSelectedIndex,
      'updatedAtEpochMs': updatedAtEpochMs,
      'pendingLaughMemeId': pendingLaughMemeId,
      'emptyText': emptyText,
      'signedOutText': signedOutText,
      'laughActionText': laughActionText,
      'unlaughActionText': unlaughActionText,
      'ownerActionText': ownerActionText,
    };
  }

  /// Returns a copy with selectively replaced fields.
  MemeWidgetSnapshotEntity copyWith({
    MemeWidgetSnapshotStatus? status,
    List<MemeWidgetItemEntity>? items,
    int? selectedIndex,
    int? updatedAtEpochMs,
    String? pendingLaughMemeId,
    bool clearPendingLaughMemeId = false,
    String? emptyText,
    String? signedOutText,
    String? laughActionText,
    String? unlaughActionText,
    String? ownerActionText,
  }) {
    return MemeWidgetSnapshotEntity(
      status: status ?? this.status,
      items: items ?? this.items,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      updatedAtEpochMs: updatedAtEpochMs ?? this.updatedAtEpochMs,
      pendingLaughMemeId: clearPendingLaughMemeId
          ? null
          : (pendingLaughMemeId ?? this.pendingLaughMemeId),
      emptyText: emptyText ?? this.emptyText,
      signedOutText: signedOutText ?? this.signedOutText,
      laughActionText: laughActionText ?? this.laughActionText,
      unlaughActionText: unlaughActionText ?? this.unlaughActionText,
      ownerActionText: ownerActionText ?? this.ownerActionText,
    );
  }

  static MemeWidgetSnapshotStatus _parseStatus(String rawStatus) {
    return switch (rawStatus) {
      'signedOut' || 'signed_out' => MemeWidgetSnapshotStatus.signedOut,
      'ready' => MemeWidgetSnapshotStatus.ready,
      _ => MemeWidgetSnapshotStatus.empty,
    };
  }
}
