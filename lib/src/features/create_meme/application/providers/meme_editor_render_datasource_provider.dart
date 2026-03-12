import 'package:memuno_app/src/features/create_meme/data/datasources/local_meme_editor_render_datasource_impl.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_editor_render_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_editor_render_datasource_provider.g.dart';

/// Provides the local meme-editor render datasource implementation.
@Riverpod(keepAlive: true)
MemeEditorRenderDatasource memeEditorRenderDatasource(Ref ref) {
  return const LocalMemeEditorRenderDatasourceImpl();
}
