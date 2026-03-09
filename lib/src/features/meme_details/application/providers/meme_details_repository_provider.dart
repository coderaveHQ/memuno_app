import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_datasource_provider.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_mapper_provider.dart';
import 'package:memuno_app/src/features/meme_details/data/datasources/meme_details_datasource.dart';
import 'package:memuno_app/src/features/meme_details/data/mappers/meme_details_mapper.dart';
import 'package:memuno_app/src/features/meme_details/data/repositories/meme_details_repository_impl.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_details_repository_provider.g.dart';

/// Provides the meme-details repository implementation.
@Riverpod(keepAlive: true)
MemeDetailsRepository memeDetailsRepository(Ref ref) {
  final MemeDetailsDatasource datasource = ref.watch(
    memeDetailsDatasourceProvider,
  );
  final MemeDetailsMapper mapper = ref.watch(memeDetailsMapperProvider);
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return MemeDetailsRepositoryImpl(
    memeDetailsDatasource: datasource,
    memeDetailsMapper: mapper,
    failureMapper: failureMapper,
  );
}
