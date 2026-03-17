import 'dart:typed_data';

import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_editor_state_entity.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_send_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';

/// Usecase for sending one finalized meme to selected recipients.
final class SendMemeUsecase {
  /// Creates the usecase.
  const SendMemeUsecase({
    required MemeSendRepository repository,
    required MemeEditorValidator validator,
  }) : _repository = repository,
       _validator = validator;

  /// Repository used for storage upload and RPC execution.
  final MemeSendRepository _repository;

  /// Validator used for request input checks.
  final MemeEditorValidator _validator;

  /// Sends one finalized meme from [state] and [memeBytes].
  Future<void> call({
    /// Current editor snapshot with selected background and recipient selection.
    required MemeEditorStateEntity state,

    /// Finalized PNG bytes to upload.
    required Uint8List memeBytes,
  }) async {
    final Failure? templateSelectedValidation = _validator
        .validateTemplateSelected(state);
    if (templateSelectedValidation != null) {
      throw templateSelectedValidation;
    }

    final Failure? bytesValidation = _validator.validateFinalizedBytes(
      memeBytes,
    );
    if (bytesValidation != null) {
      throw bytesValidation;
    }

    final Failure? recipientsValidation = _validator
        .validateRecipientSelections(
          recipientUserIds: state.selectedRecipientUserIds,
          recipientGroupIds: state.selectedRecipientGroupIds,
        );
    if (recipientsValidation != null) {
      throw recipientsValidation;
    }

    final List<String> recipientUserIds = state.selectedRecipientUserIds.toList(
      growable: false,
    )..sort();
    final List<String> recipientGroupIds =
        state.selectedRecipientGroupIds.toList(growable: false)..sort();

    for (final String recipientUserId in recipientUserIds) {
      final Failure? recipientValidation = _validator.validateFriendUserId(
        recipientUserId,
      );
      if (recipientValidation != null) {
        throw recipientValidation;
      }
    }

    for (final String recipientGroupId in recipientGroupIds) {
      final Failure? recipientValidation = _validator.validateGroupId(
        recipientGroupId,
      );
      if (recipientValidation != null) {
        throw recipientValidation;
      }
    }

    final template = state.template;
    if (template == null) {
      throw const Failure.validation(code: 'invalid_format', field: 'template');
    }

    final String templateId = template.id;
    final Failure? templateIdValidation = _validator.validateTemplateId(
      templateId,
    );
    if (templateIdValidation != null) {
      throw templateIdValidation;
    }

    final double aspectRatio = template.aspectRatio;

    final Failure? aspectRatioValidation = _validator.validateAspectRatio(
      aspectRatio,
    );
    if (aspectRatioValidation != null) {
      throw aspectRatioValidation;
    }

    await _repository.sendMeme(
      memeBytes: memeBytes,
      templateId: templateId,
      aspectRatio: aspectRatio,
      recipientUserIds: recipientUserIds,
      recipientGroupIds: recipientGroupIds,
    );
  }
}
