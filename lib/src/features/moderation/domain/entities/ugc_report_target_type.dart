/// Report target categories stored in `public.ugc_reports.target_type`.
enum UgcReportTargetType {
  user('user'),
  group('group'),
  meme('meme');

  const UgcReportTargetType(this.databaseValue);

  /// Raw enum value persisted in Postgres.
  final String databaseValue;
}
