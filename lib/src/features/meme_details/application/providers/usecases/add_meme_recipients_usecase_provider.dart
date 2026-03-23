import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_repository_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/add_meme_recipients_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_meme_recipients_usecase_provider.g.dart';

/// Provides [AddMemeRecipientsUsecase].
@riverpod
AddMemeRecipientsUsecase addMemeRecipientsUsecase(Ref ref) {
  final MemeDetailsRepository repository = ref.watch(
    memeDetailsRepositoryProvider,
  );
  return AddMemeRecipientsUsecase(repository: repository);
}
