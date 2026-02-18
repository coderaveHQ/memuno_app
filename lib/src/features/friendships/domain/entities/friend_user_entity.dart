import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_user_entity.freezed.dart';

/// Domain entity representing a user referenced by friendship records.
@freezed
sealed class FriendUserEntity with _$FriendUserEntity {
  /// Creates a friend user entity.
  const factory FriendUserEntity({
    /// User identifier from `public.users.id`.
    required String id,

    /// Display name from `public.users.name`.
    required String name,

    /// Friendship code from `public.users.friendship_code`.
    required String friendshipCode,
  }) = _FriendUserEntity;

  const FriendUserEntity._();
}
