import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/providers/failure_mapper_provider.dart';
import 'package:memuno_app/src/features/meme_templates/application/providers/meme_template_mapper_provider.dart';
import 'package:memuno_app/src/features/meme_templates/application/providers/meme_templates_datasource_provider.dart';
import 'package:memuno_app/src/features/meme_templates/data/datasources/meme_templates_datasource.dart';
import 'package:memuno_app/src/features/meme_templates/data/mappers/meme_template_mapper.dart';
import 'package:memuno_app/src/features/meme_templates/data/repositories/meme_templates_repository_impl.dart';
import 'package:memuno_app/src/features/meme_templates/domain/repositories/meme_templates_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_templates_repository_provider.g.dart';

/// Provides the meme-templates repository implementation.
@Riverpod(keepAlive: true)
MemeTemplatesRepository memeTemplatesRepository(Ref ref) {
  final MemeTemplatesDatasource memeTemplatesDatasource = ref.watch(
    memeTemplatesDatasourceProvider,
  );
  final MemeTemplateMapper memeTemplateMapper = ref.watch(
    memeTemplateMapperProvider,
  );
  final FailureMapper failureMapper = ref.watch(failureMapperProvider);

  return MemeTemplatesRepositoryImpl(
    memeTemplatesDatasource: memeTemplatesDatasource,
    memeTemplateMapper: memeTemplateMapper,
    failureMapper: failureMapper,
  );
}
