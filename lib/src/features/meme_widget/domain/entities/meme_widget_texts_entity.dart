/// Localized UI copy persisted in widget snapshots.
final class MemeWidgetTextsEntity {
  /// Creates one texts bundle.
  const MemeWidgetTextsEntity({
    required this.emptyText,
    required this.signedOutText,
    required this.laughActionText,
    required this.unlaughActionText,
    required this.ownerActionText,
  });

  /// Empty-state message.
  final String emptyText;

  /// Signed-out message.
  final String signedOutText;

  /// Laugh action label.
  final String laughActionText;

  /// Unlaugh action label.
  final String unlaughActionText;

  /// Owner badge/action label.
  final String ownerActionText;
}
