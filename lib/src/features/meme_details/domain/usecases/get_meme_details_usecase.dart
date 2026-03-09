import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';

/// Usecase for loading one meme details payload.
final class GetMemeDetailsUsecase {
  /// Creates the usecase.
  const GetMemeDetailsUsecase({required MemeDetailsRepository repository})
    : _repository = repository;

  final MemeDetailsRepository _repository;

  /// Executes the meme-details query.
  Future<MemeDetailsEntity> call({
    /// Meme id to load.
    required String memeId,
  }) {
    return _repository.getMemeDetails(memeId: memeId);
  }
}
