/// Group membership role for one user.
enum GroupUserType {
  creator('creator'),
  admin('admin'),
  member('member');

  const GroupUserType(this.databaseValue);

  /// Raw enum label stored in Postgres.
  final String databaseValue;

  /// Parses one database enum label into a [GroupUserType].
  static GroupUserType fromDatabaseValue(String value) {
    return switch (value) {
      'creator' => GroupUserType.creator,
      'admin' => GroupUserType.admin,
      'member' => GroupUserType.member,
      _ => throw FormatException('Unknown group_user_type value: $value'),
    };
  }
}
