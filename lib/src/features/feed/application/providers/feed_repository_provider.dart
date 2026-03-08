import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/feed/application/providers/feed_datasource_provider.dart';
import 'package:memuno_app/src/features/feed/application/providers/feed_mapper_provider.dart';
import 'package:memuno_app/src/features/feed/data/datasources/feed_datasource.dart';
import 'package:memuno_app/src/features/feed/data/mappers/feed_mapper.dart';
import 'package:memuno_app/src/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:memuno_app/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_repository_provider.g.dart';

/// Provides the feed repository implementation.
@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) {
  final FeedDatasource datasource = ref.watch(feedDatasourceProvider);
  final FeedMapper mapper = ref.watch(feedMapperProvider);
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return FeedRepositoryImpl(
    feedDatasource: datasource,
    feedMapper: mapper,
    failureMapper: failureMapper,
  );
}
