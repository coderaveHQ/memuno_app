import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/meme_widget/data/datasources/meme_widget_local_datasource.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_snapshot_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';

/// Repository implementation for local widget operations.
final class MemeWidgetLocalRepositoryImpl implements MemeWidgetLocalRepository {
  /// Creates the repository.
  const MemeWidgetLocalRepositoryImpl({
    required MemeWidgetLocalDatasource localDatasource,
    required FailureMapper failureMapper,
  }) : _localDatasource = localDatasource,
       _failureMapper = failureMapper;

  final MemeWidgetLocalDatasource _localDatasource;
  final FailureMapper _failureMapper;

  @override
  Future<void> configure() async {
    try {
      await _localDatasource.configure();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> saveSnapshot(MemeWidgetSnapshotEntity snapshot) async {
    try {
      await _localDatasource.saveSnapshot(snapshot);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<MemeWidgetSnapshotEntity?> loadSnapshot() async {
    try {
      return await _localDatasource.loadSnapshot();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> clearSnapshot() async {
    try {
      await _localDatasource.clearSnapshot();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> savePendingActionUri(String actionUri) async {
    try {
      await _localDatasource.savePendingActionUri(actionUri);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<String?> takePendingActionUri() async {
    try {
      return await _localDatasource.takePendingActionUri();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<void> refreshNativeWidget() async {
    try {
      await _localDatasource.refreshNativeWidget();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Stream<Uri> widgetClickedStream() {
    try {
      return _localDatasource.widgetClickedStream();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  @override
  Future<Uri?> initiallyLaunchedUri() async {
    try {
      return await _localDatasource.initiallyLaunchedUri();
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
