import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_send_datasource_provider.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_send_datasource.dart';
import 'package:memuno_app/src/features/create_meme/data/repositories/meme_send_repository_impl.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_send_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_send_repository_provider.g.dart';

/// Provides the send-meme repository implementation.
@Riverpod(keepAlive: true)
MemeSendRepository memeSendRepository(Ref ref) {
  final MemeSendDatasource memeSendDatasource = ref.watch(
    memeSendDatasourceProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return MemeSendRepositoryImpl(
    memeSendDatasource: memeSendDatasource,
    failureMapper: failureMapper,
  );
}
