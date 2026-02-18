/// Convenience parsing helpers for display names.
extension StringX on String? {
  /// Returns display initials from a full name.
  ///
  /// Examples:
  /// - `"Ada Lovelace"` -> `"AL"`
  /// - `"Ada"` -> `"A"`
  /// - `null`/empty -> `"--"`
  String get initials {
    final List<String> parts = _parts;
    if (parts.isEmpty) {
      return '--';
    }

    final String first = _firstCharacter(parts.first);
    if (parts.length == 1) {
      return first;
    }

    final String last = _firstCharacter(parts.last);
    return '$first$last';
  }

  /// Returns the first name from a full name.
  ///
  /// Examples:
  /// - `"Ada Lovelace"` -> `"Ada"`
  /// - `"  Ada   Lovelace  "` -> `"Ada"`
  /// - `null`/empty -> `""`
  String get firstName {
    final List<String> parts = _parts;
    if (parts.isEmpty) {
      return '';
    }

    return parts.first;
  }

  List<String> get _parts => (this ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((String part) => part.isNotEmpty)
      .toList(growable: false);

  String _firstCharacter(String value) {
    if (value.isEmpty) {
      return '-';
    }

    return String.fromCharCode(value.runes.first).toUpperCase();
  }
}
