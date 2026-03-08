import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_dto.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_item_dto.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_item_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_item_user_entity.dart';

/// Maps feed DTOs into domain entities.
final class FeedMapper {
  /// Creates a mapper.
  const FeedMapper();

  /// Maps one feed-list item DTO to the domain entity.
  FeedListPageItemEntity toDomain(FeedListPageItemDto dto) {
    return FeedListPageItemEntity(
      meme: _memeToDomain(dto.meme),
      user: _userToDomain(dto.user),
    );
  }

  /// Maps one feed-list page DTO to the domain entity.
  FeedListPageEntity pageToDomain(FeedListPageDto dto) {
    return FeedListPageEntity(
      items: dto.items.map(toDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  FeedListPageItemMemeEntity _memeToDomain(FeedListPageItemMemeDto dto) {
    final String? signedImageUrl = dto.signedImageUrl;
    if (signedImageUrl == null || signedImageUrl.isEmpty) {
      throw FormatException(
        'Missing signed image URL for feed meme `${dto.id}`.',
      );
    }

    if (dto.aspectRatio <= 0) {
      throw FormatException('Invalid aspect ratio for feed meme `${dto.id}`.');
    }
    if (dto.laughCount < 0) {
      throw FormatException('Invalid laugh count for feed meme `${dto.id}`.');
    }

    return FeedListPageItemMemeEntity(
      id: dto.id,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      laughCount: dto.laughCount,
      isLaughed: dto.isLaughed,
    );
  }

  FeedListPageItemUserEntity _userToDomain(FeedListPageItemUserDto dto) {
    return FeedListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
