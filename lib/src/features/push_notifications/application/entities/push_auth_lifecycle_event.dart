/// Authentication lifecycle events relevant for push-token orchestration.
enum PushAuthLifecycleEvent {
  /// A signed-in session is available for the current user id.
  sessionAvailable,

  /// The signed-in session has ended.
  sessionEnded,
}
