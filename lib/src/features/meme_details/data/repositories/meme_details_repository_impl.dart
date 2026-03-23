import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/meme_details/data/datasources/meme_details_datasource.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_details_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_recipient_target_item_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/mappers/meme_details_mapper.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_type.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';

/// Repository implementation for meme details feature operations.
final class MemeDetailsRepositoryImpl implements MemeDetailsRepository {
  /// Creates the repository.
  const MemeDetailsRepositoryImpl({
    required MemeDetailsDatasource memeDetailsDatasource,
    required MemeDetailsMapper memeDetailsMapper,
    required FailureMapper failureMapper,
  }) : _memeDetailsDatasource = memeDetailsDatasource,
       _memeDetailsMapper = memeDetailsMapper,
       _failureMapper = failureMapper;

  final MemeDetailsDatasource _memeDetailsDatasource;
  final MemeDetailsMapper _memeDetailsMapper;
  final FailureMapper _failureMapper;

  @override
  /// Loads one meme-details payload and maps it to domain entities.
  Future<MemeDetailsEntity> getMemeDetails({required String memeId}) async {
    try {
      final MemeDetailsDto dto = await _memeDetailsDatasource.getMemeDetails(
        memeId: memeId,
      );

      return _memeDetailsMapper.detailsToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads one meme-laugh-list page and maps it to domain entities.
  Future<MemeLaughListPageEntity> listMemeLaughs({
    required String memeId,
    required int limit,
    MemeLaughCursorEntity? cursor,
  }) async {
    try {
      final MemeLaughListPageDto dto = await _memeDetailsDatasource
          .listMemeLaughs(
            memeId: memeId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );

      return _memeDetailsMapper.laughPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads one recipient-target list page and maps it to domain entities.
  Future<ListPageEntity<MemeRecipientTargetItemEntity>> listMemeRecipients({
    required String memeId,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<MemeRecipientTargetItemDto> dto =
          await _memeDetailsDatasource.listMemeRecipients(
            memeId: memeId,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );

      return _memeDetailsMapper.recipientTargetPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Loads one addable recipient-target list page and maps it to domain entities.
  Future<ListPageEntity<MemeRecipientTargetItemEntity>>
  listMemeAddableRecipientTargets({
    required String memeId,
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<MemeRecipientTargetItemDto> dto =
          await _memeDetailsDatasource.listMemeAddableRecipientTargets(
            memeId: memeId,
            search: search,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );

      return _memeDetailsMapper.recipientTargetPageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Adds one or more recipient targets to one meme.
  Future<void> addMemeRecipients({
    required String memeId,
    required List<String> recipientUserIds,
    required List<String> recipientGroupIds,
  }) async {
    try {
      await _memeDetailsDatasource.addMemeRecipients(
        memeId: memeId,
        recipientUserIds: recipientUserIds,
        recipientGroupIds: recipientGroupIds,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Removes one recipient target from one meme and returns the deletion flag.
  Future<bool> removeMemeRecipient({
    required String memeId,
    required MemeRecipientTargetType targetType,
    required String targetId,
  }) async {
    try {
      return _memeDetailsDatasource.removeMemeRecipient(
        memeId: memeId,
        targetType: targetType,
        targetId: targetId,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Toggles the current user's laugh state for one meme.
  Future<bool> toggleMemeLaugh({required String memeId}) async {
    try {
      return _memeDetailsDatasource.toggleMemeLaugh(memeId: memeId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Deletes one meme owned by the current user.
  Future<void> deleteMeme({required String memeId}) async {
    try {
      await _memeDetailsDatasource.deleteMeme(memeId: memeId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
