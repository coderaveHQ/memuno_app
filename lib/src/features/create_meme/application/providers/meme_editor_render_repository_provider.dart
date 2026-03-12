import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_render_datasource_provider.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_editor_render_datasource.dart';
import 'package:memuno_app/src/features/create_meme/data/repositories/meme_editor_render_repository_impl.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_editor_render_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_editor_render_repository_provider.g.dart';

/// Provides the meme-editor render repository implementation.
@Riverpod(keepAlive: true)
MemeEditorRenderRepository memeEditorRenderRepository(Ref ref) {
  final MemeEditorRenderDatasource memeEditorRenderDatasource = ref.watch(
    memeEditorRenderDatasourceProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return MemeEditorRenderRepositoryImpl(
    memeEditorRenderDatasource: memeEditorRenderDatasource,
    failureMapper: failureMapper,
  );
}
