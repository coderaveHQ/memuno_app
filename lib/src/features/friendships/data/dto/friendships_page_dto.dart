// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/friendships/data/dto/friendship_dto.dart';

part 'friendships_page_dto.freezed.dart';
part 'friendships_page_dto.g.dart';

/// DTO representing one paginated response from `friendships_list` RPC.
@freezed
sealed class FriendshipsPageDto with _$FriendshipsPageDto {
  /// Creates a friendships page DTO.
  const factory FriendshipsPageDto({
    /// Friendship items contained in the page.
    required List<FriendshipDto> items,

    /// Next cursor name value for pagination.
    @JsonKey(name: 'next_cursor_name') String? nextCursorName,

    /// Next cursor id value for pagination.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _FriendshipsPageDto;

  /// Creates a friendships page DTO from JSON.
  factory FriendshipsPageDto.fromJson(Map<String, Object?> json) =>
      _$FriendshipsPageDtoFromJson(json);
}
