import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';

/// Usecase for adding one or more recipients to one owned meme.
final class AddMemeRecipientsUsecase {
  const AddMemeRecipientsUsecase({required MemeDetailsRepository repository})
    : _repository = repository;

  final MemeDetailsRepository _repository;

  Future<void> call({
    required String memeId,
    required List<String> recipientUserIds,
    required List<String> recipientGroupIds,
  }) {
    return _repository.addMemeRecipients(
      memeId: memeId,
      recipientUserIds: recipientUserIds,
      recipientGroupIds: recipientGroupIds,
    );
  }
}
