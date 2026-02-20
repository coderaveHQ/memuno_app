import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/meme_templates/data/datasources/meme_templates_datasource.dart';
import 'package:memuno_app/src/features/meme_templates/data/dto/meme_templates_page_dto.dart';
import 'package:memuno_app/src/features/meme_templates/data/mappers/meme_template_mapper.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_cursor_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';
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
  /// Loads one paginated meme-templates page and maps it to domain entities.
  Future<PaginatedPage<MemeTemplateEntity, MemeTemplateCursorEntity>>
  listMemeTemplates({
    String? search,
    required int limit,
    MemeTemplateCursorEntity? cursor,
  }) async {
    try {
      final MemeTemplatesPageDto dto = await _memeTemplatesDatasource
          .listMemeTemplates(
            search: search,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );

      return PaginatedPage<MemeTemplateEntity, MemeTemplateCursorEntity>(
        items: dto.items
            .map(_memeTemplateMapper.toDomain)
            .toList(growable: false),
        nextCursor: _cursorFrom(dto),
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }

  /// Maps page cursor fields into a cursor entity.
  MemeTemplateCursorEntity? _cursorFrom(MemeTemplatesPageDto dto) {
    final DateTime? nextCursorCreatedAt = dto.nextCursorCreatedAt;
    final String? nextCursorId = dto.nextCursorId;

    if (nextCursorCreatedAt == null || nextCursorId == null) {
      return null;
    }

    return MemeTemplateCursorEntity(
      createdAt: nextCursorCreatedAt,
      id: nextCursorId,
    );
  }
}
