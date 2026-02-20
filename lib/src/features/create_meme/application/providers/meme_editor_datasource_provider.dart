import 'package:memuno_app/src/features/create_meme/data/datasources/in_memory_meme_editor_datasource_impl.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_editor_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_editor_datasource_provider.g.dart';

/// Provides the local meme-editor datasource implementation.
@Riverpod(keepAlive: true)
MemeEditorDatasource memeEditorDatasource(Ref ref) {
  return InMemoryMemeEditorDatasourceImpl();
}
