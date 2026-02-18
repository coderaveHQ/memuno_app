// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_request_dto.dart';

part 'friendship_requests_page_dto.freezed.dart';
part 'friendship_requests_page_dto.g.dart';

/// DTO representing one paginated response from `friendship_requests_list` RPC.
@freezed
sealed class FriendshipRequestsPageDto with _$FriendshipRequestsPageDto {
  /// Creates a friendship-requests page DTO.
  const factory FriendshipRequestsPageDto({
    /// Friendship-request items contained in the page.
    required List<FriendshipRequestDto> items,

    /// Next cursor created-at value for pagination.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor id value for pagination.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _FriendshipRequestsPageDto;

  /// Creates a friendship-requests page DTO from JSON.
  factory FriendshipRequestsPageDto.fromJson(Map<String, Object?> json) =>
      _$FriendshipRequestsPageDtoFromJson(json);
}
