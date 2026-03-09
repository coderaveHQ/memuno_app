import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_repository_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/toggle_meme_details_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_meme_details_laugh_usecase_provider.g.dart';

/// Provides [ToggleMemeDetailsLaughUsecase].
@riverpod
ToggleMemeDetailsLaughUsecase toggleMemeDetailsLaughUsecase(Ref ref) {
  final MemeDetailsRepository repository = ref.watch(
    memeDetailsRepositoryProvider,
  );
  return ToggleMemeDetailsLaughUsecase(repository: repository);
}
