import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_repository_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/remove_meme_recipient_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'remove_meme_recipient_usecase_provider.g.dart';

/// Provides [RemoveMemeRecipientUsecase].
@riverpod
RemoveMemeRecipientUsecase removeMemeRecipientUsecase(Ref ref) {
  final MemeDetailsRepository repository = ref.watch(
    memeDetailsRepositoryProvider,
  );
  return RemoveMemeRecipientUsecase(repository: repository);
}
