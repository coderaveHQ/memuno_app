import 'package:memuno_app/src/features/create_meme/application/providers/meme_recipient_targets_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_recipient_targets_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/list_meme_recipient_targets_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_meme_recipient_targets_usecase_provider.g.dart';

/// Provides the recipient-target list usecase.
@riverpod
ListMemeRecipientTargetsUsecase listMemeRecipientTargetsUsecase(Ref ref) {
  final MemeRecipientTargetsRepository repository = ref.watch(
    memeRecipientTargetsRepositoryProvider,
  );
  return ListMemeRecipientTargetsUsecase(repository: repository);
}
