import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/meme_widget/data/datasources/meme_widget_remote_datasource.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_item_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_remote_repository.dart';

/// Repository implementation for remote widget operations.
final class MemeWidgetRemoteRepositoryImpl
    implements MemeWidgetRemoteRepository {
  /// Creates the repository.
  const MemeWidgetRemoteRepositoryImpl({
    required MemeWidgetRemoteDatasource remoteDatasource,
    required FailureMapper failureMapper,
  }) : _remoteDatasource = remoteDatasource,
       _failureMapper = failureMapper;

  final MemeWidgetRemoteDatasource _remoteDatasource;
  final FailureMapper _failureMapper;

  @override
  Future<List<MemeWidgetItemEntity>> loadLatestItems({
    required int limit,
  }) async {
    try {
      return await _remoteDatasource.loadLatestItems(limit: limit);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<bool> toggleMemeLaugh({required String memeId}) async {
    try {
      return await _remoteDatasource.toggleMemeLaugh(memeId: memeId);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
