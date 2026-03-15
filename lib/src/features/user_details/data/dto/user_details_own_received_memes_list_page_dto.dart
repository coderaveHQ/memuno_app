// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_item_dto.dart';

part 'user_details_own_received_memes_list_page_dto.freezed.dart';
part 'user_details_own_received_memes_list_page_dto.g.dart';

/// DTO matching `public.user_details_own_received_memes_list_page`.
@freezed
sealed class UserDetailsOwnReceivedMemesListPageDto
    with _$UserDetailsOwnReceivedMemesListPageDto {
  /// Creates one own-received memes-list page DTO.
  const factory UserDetailsOwnReceivedMemesListPageDto({
    /// Page items.
    required List<UserDetailsOwnReceivedMemesListPageItemDto> items,

    /// Next cursor `created_at` value.
    @JsonKey(name: 'next_cursor_created_at') DateTime? nextCursorCreatedAt,

    /// Next cursor `id` value.
    @JsonKey(name: 'next_cursor_id') String? nextCursorId,
  }) = _UserDetailsOwnReceivedMemesListPageDto;

  /// Creates one own-received memes-list page DTO from JSON.
  factory UserDetailsOwnReceivedMemesListPageDto.fromJson(
    Map<String, Object?> json,
  ) => _$UserDetailsOwnReceivedMemesListPageDtoFromJson(json);
}
