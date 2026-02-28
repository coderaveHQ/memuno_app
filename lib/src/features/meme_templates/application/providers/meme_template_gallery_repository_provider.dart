import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/meme_templates/application/providers/meme_template_gallery_datasource_provider.dart';
import 'package:memuno_app/src/features/meme_templates/data/datasources/meme_template_gallery_datasource.dart';
import 'package:memuno_app/src/features/meme_templates/data/repositories/meme_template_gallery_repository_impl.dart';
import 'package:memuno_app/src/features/meme_templates/domain/repositories/meme_template_gallery_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_template_gallery_repository_provider.g.dart';

/// Provides the meme-template gallery repository implementation.
@Riverpod(keepAlive: true)
MemeTemplateGalleryRepository memeTemplateGalleryRepository(Ref ref) {
  final MemeTemplateGalleryDatasource datasource = ref.watch(
    memeTemplateGalleryDatasourceProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return MemeTemplateGalleryRepositoryImpl(
    memeTemplateGalleryDatasource: datasource,
    failureMapper: failureMapper,
  );
}
