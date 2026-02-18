// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friend_user_dto.dart';

part 'friendship_request_dto.freezed.dart';
part 'friendship_request_dto.g.dart';

/// DTO representing one friendship-request list item.
@freezed
sealed class FriendshipRequestDto with _$FriendshipRequestDto {
  /// Creates a friendship-request DTO.
  const factory FriendshipRequestDto({
    /// Surrogate request identifier from `public.friendship_requests.id`.
    required String id,

    /// User payload for the other request participant.
    required FriendUserDto user,

    /// Raw status value from SQL enum.
    required String status,

    /// Request creation timestamp.
    @JsonKey(name: 'created_at') required DateTime createdAt,

    /// Request update timestamp.
    @JsonKey(name: 'updated_at') required DateTime updatedAt,

    /// Raw direction value (`incoming` / `outgoing`).
    required String direction,
  }) = _FriendshipRequestDto;

  /// Creates a friendship-request DTO from JSON.
  factory FriendshipRequestDto.fromJson(Map<String, Object?> json) =>
      _$FriendshipRequestDtoFromJson(json);
}
