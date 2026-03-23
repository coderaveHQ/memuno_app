import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_repository_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/list_meme_addable_recipient_targets_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_meme_addable_recipient_targets_usecase_provider.g.dart';

/// Provides [ListMemeAddableRecipientTargetsUsecase].
@riverpod
ListMemeAddableRecipientTargetsUsecase listMemeAddableRecipientTargetsUsecase(
  Ref ref,
) {
  final MemeDetailsRepository repository = ref.watch(
    memeDetailsRepositoryProvider,
  );
  return ListMemeAddableRecipientTargetsUsecase(repository: repository);
}
