import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/meme_details/data/datasources/meme_details_datasource.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_details_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/dto/meme_laugh_list_page_dto.dart';
import 'package:memuno_app/src/features/meme_details/data/mappers/meme_details_mapper.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_entity.dart';
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
  /// Toggles the current user's laugh state for one meme.
  Future<bool> toggleMemeLaugh({required String memeId}) async {
    try {
      return _memeDetailsDatasource.toggleMemeLaugh(memeId: memeId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
