import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_recipient_targets_datasource.dart';
import 'package:memuno_app/src/features/create_meme/data/dto/meme_recipient_target_item_dto.dart';
import 'package:memuno_app/src/features/create_meme/data/mappers/meme_recipient_target_mapper.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_recipient_targets_repository.dart';

/// Repository implementation for recipient-target list operations.
final class MemeRecipientTargetsRepositoryImpl
    implements MemeRecipientTargetsRepository {
  const MemeRecipientTargetsRepositoryImpl({
    required MemeRecipientTargetsDatasource datasource,
    required MemeRecipientTargetMapper mapper,
    required FailureMapper failureMapper,
  }) : _datasource = datasource,
       _mapper = mapper,
       _failureMapper = failureMapper;

  final MemeRecipientTargetsDatasource _datasource;
  final MemeRecipientTargetMapper _mapper;
  final FailureMapper _failureMapper;

  @override
  Future<ListPageEntity<MemeRecipientTargetItemEntity>> listRecipientTargets({
    String? search,
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    try {
      final ListPageDto<MemeRecipientTargetItemDto> dto = await _datasource
          .listRecipientTargets(
            search: search,
            limit: limit,
            cursorCreatedAt: cursor?.createdAt,
            cursorId: cursor?.id,
          );
      return _mapper.pageToDomain(dto);
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
