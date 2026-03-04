import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_send_datasource.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_send_repository.dart';

/// Repository implementation for send-meme operations.
final class MemeSendRepositoryImpl implements MemeSendRepository {
  /// Creates the repository.
  const MemeSendRepositoryImpl({
    required MemeSendDatasource memeSendDatasource,
    required FailureMapper failureMapper,
  }) : _memeSendDatasource = memeSendDatasource,
       _failureMapper = failureMapper;

  /// Datasource used for storage upload and RPC execution.
  final MemeSendDatasource _memeSendDatasource;

  /// Mapper used to normalize thrown errors into failures.
  final FailureMapper _failureMapper;

  @override
  Future<void> sendMeme({
    required Uint8List memeBytes,
    required String? templateId,
    required double aspectRatio,
    required List<String> recipientUserIds,
  }) async {
    try {
      await _memeSendDatasource.sendMeme(
        memeBytes: memeBytes,
        templateId: templateId,
        aspectRatio: aspectRatio,
        recipientUserIds: recipientUserIds,
      );
    } catch (error) {
      throw _failureMapper.map(error);
    }
  }
}
