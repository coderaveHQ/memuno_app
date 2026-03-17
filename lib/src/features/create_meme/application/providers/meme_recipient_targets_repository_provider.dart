import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_recipient_target_mapper_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_recipient_targets_datasource_provider.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_recipient_targets_datasource.dart';
import 'package:memuno_app/src/features/create_meme/data/mappers/meme_recipient_target_mapper.dart';
import 'package:memuno_app/src/features/create_meme/data/repositories/meme_recipient_targets_repository_impl.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_recipient_targets_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_recipient_targets_repository_provider.g.dart';

/// Provides the recipient-target repository implementation.
@Riverpod(keepAlive: true)
MemeRecipientTargetsRepository memeRecipientTargetsRepository(Ref ref) {
  final MemeRecipientTargetsDatasource datasource = ref.watch(
    memeRecipientTargetsDatasourceProvider,
  );
  final MemeRecipientTargetMapper mapper = ref.watch(
    memeRecipientTargetMapperProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return MemeRecipientTargetsRepositoryImpl(
    datasource: datasource,
    mapper: mapper,
    failureMapper: failureMapper,
  );
}
