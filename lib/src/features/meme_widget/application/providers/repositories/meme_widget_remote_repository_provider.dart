import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/datasources/meme_widget_remote_datasource_provider.dart';
import 'package:memuno_app/src/features/meme_widget/data/datasources/meme_widget_remote_datasource.dart';
import 'package:memuno_app/src/features/meme_widget/data/repositories/meme_widget_remote_repository_impl.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_remote_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_widget_remote_repository_provider.g.dart';

/// Provides remote repository implementation for meme widget operations.
@Riverpod(keepAlive: true)
MemeWidgetRemoteRepository memeWidgetRemoteRepository(Ref ref) {
  final MemeWidgetRemoteDatasource remoteDatasource = ref.watch(
    memeWidgetRemoteDatasourceProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return MemeWidgetRemoteRepositoryImpl(
    remoteDatasource: remoteDatasource,
    failureMapper: failureMapper,
  );
}
