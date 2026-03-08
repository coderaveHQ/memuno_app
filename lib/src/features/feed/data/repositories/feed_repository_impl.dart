import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/feed/data/datasources/feed_datasource.dart';
import 'package:memuno_app/src/features/feed/data/dto/feed_list_page_dto.dart';
import 'package:memuno_app/src/features/feed/data/mappers/feed_mapper.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_cursor_entity.dart';
import 'package:memuno_app/src/features/feed/domain/entities/feed_list_page_entity.dart';
import 'package:memuno_app/src/features/feed/domain/repositories/feed_repository.dart';

/// Repository implementation for feed feature operations.
final class FeedRepositoryImpl implements FeedRepository {
  /// Creates the repository.
  const FeedRepositoryImpl({
    required FeedDatasource feedDatasource,
    required FeedMapper feedMapper,
    required FailureMapper failureMapper,
  }) : _feedDatasource = feedDatasource,
       _feedMapper = feedMapper,
       _failureMapper = failureMapper;

  final FeedDatasource _feedDatasource;
  final FeedMapper _feedMapper;
  final FailureMapper _failureMapper;

  @override
  /// Loads one feed-list page and maps it to domain entities.
  Future<FeedListPageEntity> listFeed({
    required int limit,
    FeedCursorEntity? cursor,
  }) async {
    try {
      final FeedListPageDto dto = await _feedDatasource.listFeed(
        limit: limit,
        cursorCreatedAt: cursor?.createdAt,
        cursorId: cursor?.id,
      );
      return _feedMapper.pageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  /// Toggles the current user's laugh state for one meme.
  Future<bool> toggleMemeLaugh({required String memeId}) async {
    try {
      return await _feedDatasource.toggleMemeLaugh(memeId: memeId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
