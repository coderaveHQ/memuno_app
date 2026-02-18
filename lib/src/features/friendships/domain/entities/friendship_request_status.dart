/// Status values used by friendship requests.
enum FriendshipRequestStatus {
  /// Request exists and still requires action.
  pending,

  /// Request was accepted and converted into a friendship.
  accepted,

  /// Request was declined by the addressee.
  declined,

  /// Request was canceled by the requester.
  canceled,
}
