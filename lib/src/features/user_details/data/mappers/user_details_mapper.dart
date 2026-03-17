import 'package:memuno_app/src/features/user_details/data/dto/user_details_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_all_memes_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_sent_memes_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_own_received_memes_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_all_memes_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_sent_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_sent_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_sent_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_sent_memes_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_item_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_item_meme_dto.dart';
import 'package:memuno_app/src/features/user_details/data/dto/user_details_other_received_memes_list_page_item_user_dto.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_all_memes_list_page_item_user_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_sent_memes_list_page_item_user_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_own_received_memes_list_page_item_user_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_all_memes_list_page_item_user_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_sent_memes_list_page_item_user_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_item_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_item_meme_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_other_received_memes_list_page_item_user_entity.dart';

/// Maps user-details DTO values into domain entities.
final class UserDetailsMapper {
  /// Creates a mapper.
  const UserDetailsMapper();

  /// Maps one user-details DTO to the domain entity.
  UserDetailsEntity toDomain(UserDetailsDto dto) {
    return UserDetailsEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      isFriend: dto.isFriend,
      hasPendingFriendshipRequest: dto.hasPendingFriendshipRequest,
    );
  }

  /// Maps one own\-all memes-list page DTO to the domain entity.
  UserDetailsOwnAllMemesListPageEntity ownAllPageToDomain(
    UserDetailsOwnAllMemesListPageDto dto,
  ) {
    return UserDetailsOwnAllMemesListPageEntity(
      items: dto.items.map(ownAllItemToDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  /// Maps one own\-all memes-list item DTO to the domain entity.
  UserDetailsOwnAllMemesListPageItemEntity ownAllItemToDomain(
    UserDetailsOwnAllMemesListPageItemDto dto,
  ) {
    return UserDetailsOwnAllMemesListPageItemEntity(
      meme: _ownAllMemeToDomain(dto.meme),
      user: _ownAllUserToDomain(dto.user),
    );
  }

  UserDetailsOwnAllMemesListPageItemMemeEntity _ownAllMemeToDomain(
    UserDetailsOwnAllMemesListPageItemMemeDto dto,
  ) {
    final String signedImageUrl = _requiredSignedImageUrl(
      dto.signedImageUrl,
      memeId: dto.id,
      scope: 'own_all',
    );

    _validateAspectRatio(dto.aspectRatio, memeId: dto.id, scope: 'own_all');
    _validateLaughCount(dto.laughCount, memeId: dto.id, scope: 'own_all');

    return UserDetailsOwnAllMemesListPageItemMemeEntity(
      id: dto.id,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      laughCount: dto.laughCount,
      isLaughed: dto.isLaughed,
    );
  }

  UserDetailsOwnAllMemesListPageItemUserEntity _ownAllUserToDomain(
    UserDetailsOwnAllMemesListPageItemUserDto dto,
  ) {
    return UserDetailsOwnAllMemesListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps one own\-sent memes-list page DTO to the domain entity.
  UserDetailsOwnSentMemesListPageEntity ownSentPageToDomain(
    UserDetailsOwnSentMemesListPageDto dto,
  ) {
    return UserDetailsOwnSentMemesListPageEntity(
      items: dto.items.map(ownSentItemToDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  /// Maps one own\-sent memes-list item DTO to the domain entity.
  UserDetailsOwnSentMemesListPageItemEntity ownSentItemToDomain(
    UserDetailsOwnSentMemesListPageItemDto dto,
  ) {
    return UserDetailsOwnSentMemesListPageItemEntity(
      meme: _ownSentMemeToDomain(dto.meme),
      user: _ownSentUserToDomain(dto.user),
    );
  }

  UserDetailsOwnSentMemesListPageItemMemeEntity _ownSentMemeToDomain(
    UserDetailsOwnSentMemesListPageItemMemeDto dto,
  ) {
    final String signedImageUrl = _requiredSignedImageUrl(
      dto.signedImageUrl,
      memeId: dto.id,
      scope: 'own_sent',
    );

    _validateAspectRatio(dto.aspectRatio, memeId: dto.id, scope: 'own_sent');
    _validateLaughCount(dto.laughCount, memeId: dto.id, scope: 'own_sent');

    return UserDetailsOwnSentMemesListPageItemMemeEntity(
      id: dto.id,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      laughCount: dto.laughCount,
      isLaughed: dto.isLaughed,
    );
  }

  UserDetailsOwnSentMemesListPageItemUserEntity _ownSentUserToDomain(
    UserDetailsOwnSentMemesListPageItemUserDto dto,
  ) {
    return UserDetailsOwnSentMemesListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps one own\-received memes-list page DTO to the domain entity.
  UserDetailsOwnReceivedMemesListPageEntity ownReceivedPageToDomain(
    UserDetailsOwnReceivedMemesListPageDto dto,
  ) {
    return UserDetailsOwnReceivedMemesListPageEntity(
      items: dto.items.map(ownReceivedItemToDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  /// Maps one own\-received memes-list item DTO to the domain entity.
  UserDetailsOwnReceivedMemesListPageItemEntity ownReceivedItemToDomain(
    UserDetailsOwnReceivedMemesListPageItemDto dto,
  ) {
    return UserDetailsOwnReceivedMemesListPageItemEntity(
      meme: _ownReceivedMemeToDomain(dto.meme),
      user: _ownReceivedUserToDomain(dto.user),
    );
  }

  UserDetailsOwnReceivedMemesListPageItemMemeEntity _ownReceivedMemeToDomain(
    UserDetailsOwnReceivedMemesListPageItemMemeDto dto,
  ) {
    final String signedImageUrl = _requiredSignedImageUrl(
      dto.signedImageUrl,
      memeId: dto.id,
      scope: 'own_received',
    );

    _validateAspectRatio(
      dto.aspectRatio,
      memeId: dto.id,
      scope: 'own_received',
    );
    _validateLaughCount(dto.laughCount, memeId: dto.id, scope: 'own_received');

    return UserDetailsOwnReceivedMemesListPageItemMemeEntity(
      id: dto.id,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      laughCount: dto.laughCount,
      isLaughed: dto.isLaughed,
    );
  }

  UserDetailsOwnReceivedMemesListPageItemUserEntity _ownReceivedUserToDomain(
    UserDetailsOwnReceivedMemesListPageItemUserDto dto,
  ) {
    return UserDetailsOwnReceivedMemesListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps one other\-all memes-list page DTO to the domain entity.
  UserDetailsOtherAllMemesListPageEntity otherAllPageToDomain(
    UserDetailsOtherAllMemesListPageDto dto,
  ) {
    return UserDetailsOtherAllMemesListPageEntity(
      items: dto.items.map(otherAllItemToDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  /// Maps one other\-all memes-list item DTO to the domain entity.
  UserDetailsOtherAllMemesListPageItemEntity otherAllItemToDomain(
    UserDetailsOtherAllMemesListPageItemDto dto,
  ) {
    return UserDetailsOtherAllMemesListPageItemEntity(
      meme: _otherAllMemeToDomain(dto.meme),
      user: _otherAllUserToDomain(dto.user),
    );
  }

  UserDetailsOtherAllMemesListPageItemMemeEntity _otherAllMemeToDomain(
    UserDetailsOtherAllMemesListPageItemMemeDto dto,
  ) {
    final String signedImageUrl = _requiredSignedImageUrl(
      dto.signedImageUrl,
      memeId: dto.id,
      scope: 'other_all',
    );

    _validateAspectRatio(dto.aspectRatio, memeId: dto.id, scope: 'other_all');
    _validateLaughCount(dto.laughCount, memeId: dto.id, scope: 'other_all');

    return UserDetailsOtherAllMemesListPageItemMemeEntity(
      id: dto.id,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      laughCount: dto.laughCount,
      isLaughed: dto.isLaughed,
    );
  }

  UserDetailsOtherAllMemesListPageItemUserEntity _otherAllUserToDomain(
    UserDetailsOtherAllMemesListPageItemUserDto dto,
  ) {
    return UserDetailsOtherAllMemesListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps one other\-sent memes-list page DTO to the domain entity.
  UserDetailsOtherSentMemesListPageEntity otherSentPageToDomain(
    UserDetailsOtherSentMemesListPageDto dto,
  ) {
    return UserDetailsOtherSentMemesListPageEntity(
      items: dto.items.map(otherSentItemToDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  /// Maps one other\-sent memes-list item DTO to the domain entity.
  UserDetailsOtherSentMemesListPageItemEntity otherSentItemToDomain(
    UserDetailsOtherSentMemesListPageItemDto dto,
  ) {
    return UserDetailsOtherSentMemesListPageItemEntity(
      meme: _otherSentMemeToDomain(dto.meme),
      user: _otherSentUserToDomain(dto.user),
    );
  }

  UserDetailsOtherSentMemesListPageItemMemeEntity _otherSentMemeToDomain(
    UserDetailsOtherSentMemesListPageItemMemeDto dto,
  ) {
    final String signedImageUrl = _requiredSignedImageUrl(
      dto.signedImageUrl,
      memeId: dto.id,
      scope: 'other_sent',
    );

    _validateAspectRatio(dto.aspectRatio, memeId: dto.id, scope: 'other_sent');
    _validateLaughCount(dto.laughCount, memeId: dto.id, scope: 'other_sent');

    return UserDetailsOtherSentMemesListPageItemMemeEntity(
      id: dto.id,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      laughCount: dto.laughCount,
      isLaughed: dto.isLaughed,
    );
  }

  UserDetailsOtherSentMemesListPageItemUserEntity _otherSentUserToDomain(
    UserDetailsOtherSentMemesListPageItemUserDto dto,
  ) {
    return UserDetailsOtherSentMemesListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  /// Maps one other\-received memes-list page DTO to the domain entity.
  UserDetailsOtherReceivedMemesListPageEntity otherReceivedPageToDomain(
    UserDetailsOtherReceivedMemesListPageDto dto,
  ) {
    return UserDetailsOtherReceivedMemesListPageEntity(
      items: dto.items.map(otherReceivedItemToDomain).toList(growable: false),
      nextCursorCreatedAt: dto.nextCursorCreatedAt,
      nextCursorId: dto.nextCursorId,
    );
  }

  /// Maps one other\-received memes-list item DTO to the domain entity.
  UserDetailsOtherReceivedMemesListPageItemEntity otherReceivedItemToDomain(
    UserDetailsOtherReceivedMemesListPageItemDto dto,
  ) {
    return UserDetailsOtherReceivedMemesListPageItemEntity(
      meme: _otherReceivedMemeToDomain(dto.meme),
      user: _otherReceivedUserToDomain(dto.user),
    );
  }

  UserDetailsOtherReceivedMemesListPageItemMemeEntity
  _otherReceivedMemeToDomain(
    UserDetailsOtherReceivedMemesListPageItemMemeDto dto,
  ) {
    final String signedImageUrl = _requiredSignedImageUrl(
      dto.signedImageUrl,
      memeId: dto.id,
      scope: 'other_received',
    );

    _validateAspectRatio(
      dto.aspectRatio,
      memeId: dto.id,
      scope: 'other_received',
    );
    _validateLaughCount(
      dto.laughCount,
      memeId: dto.id,
      scope: 'other_received',
    );

    return UserDetailsOtherReceivedMemesListPageItemMemeEntity(
      id: dto.id,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
      signedImageUrl: signedImageUrl,
      aspectRatio: dto.aspectRatio,
      laughCount: dto.laughCount,
      isLaughed: dto.isLaughed,
    );
  }

  UserDetailsOtherReceivedMemesListPageItemUserEntity
  _otherReceivedUserToDomain(
    UserDetailsOtherReceivedMemesListPageItemUserDto dto,
  ) {
    return UserDetailsOtherReceivedMemesListPageItemUserEntity(
      id: dto.id,
      name: dto.name,
      friendshipCode: dto.friendshipCode,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }

  String _requiredSignedImageUrl(
    String? signedImageUrl, {
    required String memeId,
    required String scope,
  }) {
    if (signedImageUrl == null || signedImageUrl.isEmpty) {
      throw FormatException(
        'Missing signed image URL for `$scope` meme `$memeId`.',
      );
    }

    return signedImageUrl;
  }

  void _validateAspectRatio(
    double aspectRatio, {
    required String memeId,
    required String scope,
  }) {
    if (aspectRatio <= 0) {
      throw FormatException(
        'Invalid aspect ratio for `$scope` meme `$memeId`.',
      );
    }
  }

  void _validateLaughCount(
    int laughCount, {
    required String memeId,
    required String scope,
  }) {
    if (laughCount < 0) {
      throw FormatException('Invalid laugh count for `$scope` meme `$memeId`.');
    }
  }
}
