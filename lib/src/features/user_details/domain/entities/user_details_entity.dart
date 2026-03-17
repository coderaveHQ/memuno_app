import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_details_entity.freezed.dart';

/// Domain entity representing app-level user details data.
@freezed
sealed class UserDetailsEntity with _$UserDetailsEntity {
  /// Creates a user-details entity.
  const factory UserDetailsEntity({
    /// User id from `public.users.id`.
    required String id,

    /// Display name stored in `public.users.name`.
    required String name,

    /// Friendship code from `public.users.friendship_code`.
    required String friendshipCode,

    /// Creation timestamp from `public.users.created_at`.
    required DateTime createdAt,

    /// Last update timestamp from `public.users.updated_at`.
    required DateTime updatedAt,

    /// Whether auth user and viewed user are friends.
    required bool isFriend,

    /// Whether a pending friendship request exists between both users.
    required bool hasPendingFriendshipRequest,
  }) = _UserDetailsEntity;

  const UserDetailsEntity._();
}
