import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_type.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';

/// Usecase for removing one recipient target from one owned meme.
final class RemoveMemeRecipientUsecase {
  const RemoveMemeRecipientUsecase({required MemeDetailsRepository repository})
    : _repository = repository;

  final MemeDetailsRepository _repository;

  /// Returns true when the removed target was the last one and the meme was deleted.
  Future<bool> call({
    required String memeId,
    required MemeRecipientTargetType targetType,
    required String targetId,
  }) {
    return _repository.removeMemeRecipient(
      memeId: memeId,
      targetType: targetType,
      targetId: targetId,
    );
  }
}
