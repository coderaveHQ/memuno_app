import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/meme_templates/data/datasources/meme_templates_datasource.dart';
import 'package:memuno_app/src/features/meme_templates/data/dto/meme_template_list_page_dto.dart';
import 'package:memuno_app/src/features/meme_templates/data/mappers/meme_template_mapper.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_list_page_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/repositories/meme_templates_repository.dart';

/// Repository implementation for meme-template read operations.
final class MemeTemplatesRepositoryImpl implements MemeTemplatesRepository {
  /// Creates the repository.
  const MemeTemplatesRepositoryImpl({
    required MemeTemplatesDatasource memeTemplatesDatasource,
    required MemeTemplateMapper memeTemplateMapper,
    required FailureMapper failureMapper,
  }) : _memeTemplatesDatasource = memeTemplatesDatasource,
       _memeTemplateMapper = memeTemplateMapper,
       _failureMapper = failureMapper;

  /// Datasource used for RPC and signed URL calls.
  final MemeTemplatesDatasource _memeTemplatesDatasource;

  /// Mapper used for meme-template DTOs.
  final MemeTemplateMapper _memeTemplateMapper;

  /// Mapper used for converting arbitrary errors into domain failures.
  final FailureMapper _failureMapper;

  @override
  /// Loads one meme-template-list page and maps it to domain entities.
  Future<MemeTemplateListPageEntity> listMemeTemplates({
    String? search,
    required int limit,
    MemeTemplateCursorEntity? cursor,
  }) async {
    try {
      final MemeTemplateListPageDto dto = await _memeTemplatesDatasource
          .listMemeTemplates(
            search: search,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _memeTemplateMapper.pageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
