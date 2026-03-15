import 'package:memuno_app/src/features/meme_details/data/dto/meme_details_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_details_user_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_item_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_user_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_item_user_entity.dart';

/// Maps meme-details DTOs into domain entities.
final class MemeDetailsMapper {
  /// Creates a mapper.
  const MemeDetailsMapper();

  /// Maps one meme-details DTO to the domain entity.
  MemeDetailsEntity detailsToDomain(MemeDetailsDto dto) {
    final String? signedImageUrl = dto.signedImageUrl;
    if (signedImageUrl == null || signedImageUrl.isEmpty) {
      throw FormatException(
        'Missing signed image URL for meme details `${dto.id}`.',
      );
    }

    if (dto.aspectRatio <= 0) {
      throw FormatException(
        'Invalid aspect ratio for meme details `${dto.id}`.',
      );
    }

    if (dto.laughCount < 0) {
      throw FormatException(
        'Invalid laugh count for meme details `${dto.id}`.',
      );
    }

    return MemeDetailsEntity(
      id: dto.id,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      laughCount: dto.laughCount,
      isLaughed: dto.isLaughed,
      user: _detailsUserToDomain(dto.user),
    );
  }

  /// Maps one meme-laugh-list page DTO to the domain entity.
  MemeLaughListPageEntity laughPageToDomain(MemeLaughListPageDto dto) {
    return MemeLaughListPageEntity(
      items: dto.items.map(_laughItemToDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  MemeDetailsUserEntity _detailsUserToDomain(MemeDetailsUserDto dto) {
    return MemeDetailsUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  MemeLaughListPageItemEntity _laughItemToDomain(MemeLaughListPageItemDto dto) {
    return MemeLaughListPageItemEntity(
      user: _laughUserToDomain(dto.user),
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  MemeLaughListPageItemUserEntity _laughUserToDomain(
    MemeLaughListPageItemUserDto dto,
  ) {
    return MemeLaughListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
