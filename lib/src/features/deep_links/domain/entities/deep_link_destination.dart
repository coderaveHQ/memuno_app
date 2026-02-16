/// App destinations that can be opened from external deep links.
///
/// This enum keeps URI parsing independent from concrete router classes.
enum DeepLinkDestination {
  /// Root route (`/`).
  root,

  /// Auth callback route (`/auth/callback`).
  authCallback,
}
