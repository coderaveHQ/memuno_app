import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile_entity.freezed.dart';

/// Domain entity representing app-level profile data for the current user.
@freezed
sealed class UserProfileEntity with _$UserProfileEntity {
  /// Creates a user profile entity.
  const factory UserProfileEntity({
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
  }) = _UserProfileEntity;

  const UserProfileEntity._();
}
