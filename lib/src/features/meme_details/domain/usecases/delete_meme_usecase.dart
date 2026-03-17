import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';

/// Usecase for deleting one owned meme.
final class DeleteMemeUsecase {
  /// Creates the usecase.
  const DeleteMemeUsecase({required MemeDetailsRepository repository})
    : _repository = repository;

  final MemeDetailsRepository _repository;

  /// Deletes one meme owned by the current user.
  Future<void> call({required String memeId}) {
    return _repository.deleteMeme(memeId: memeId);
  }
}
