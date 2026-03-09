import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_repository_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/get_meme_details_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'get_meme_details_usecase_provider.g.dart';

/// Provides [GetMemeDetailsUsecase].
@riverpod
GetMemeDetailsUsecase getMemeDetailsUsecase(Ref ref) {
  final MemeDetailsRepository repository = ref.watch(
    memeDetailsRepositoryProvider,
  );
  return GetMemeDetailsUsecase(repository: repository);
}
