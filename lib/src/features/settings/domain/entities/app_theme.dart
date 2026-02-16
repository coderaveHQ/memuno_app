/// Theme preference selected by the user.
enum AppTheme {
  /// Follow the system appearance.
  system(storageKey: 'system'),

  /// Always use the light theme.
  light(storageKey: 'light'),

  /// Always use the dark theme.
  dark(storageKey: 'dark');

  /// Persisted key for this theme preference.
  final String storageKey;

  /// Creates an AppTheme instance.
  const AppTheme({required this.storageKey});

  /// Parses a stored key into an [AppTheme].
  static AppTheme? fromStorageKey(String? key) {
    if (key == null) {
      return null;
    }
    for (final AppTheme theme in AppTheme.values) {
      if (theme.storageKey == key) {
        return theme;
      }
    }
    return null;
  }
}
