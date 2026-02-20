import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_datasource_provider.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_editor_datasource.dart';
import 'package:memuno_app/src/features/create_meme/data/repositories/meme_editor_repository_impl.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_editor_repository_provider.g.dart';

/// Provides the meme-editor repository implementation.
@Riverpod(keepAlive: true)
MemeEditorRepository memeEditorRepository(Ref ref) {
  final MemeEditorDatasource memeEditorDatasource = ref.watch(
    memeEditorDatasourceProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return MemeEditorRepositoryImpl(
    memeEditorDatasource: memeEditorDatasource,
    failureMapper: failureMapper,
  );
}
