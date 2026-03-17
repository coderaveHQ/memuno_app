import 'package:memuno_app/src/features/meme_details/application/providers/meme_details_repository_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/repositories/meme_details_repository.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/delete_meme_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_meme_usecase_provider.g.dart';

/// Provides [DeleteMemeUsecase].
@Riverpod(keepAlive: true)
DeleteMemeUsecase deleteMemeUsecase(Ref ref) {
  final MemeDetailsRepository repository = ref.watch(
    memeDetailsRepositoryProvider,
  );
  return DeleteMemeUsecase(repository: repository);
}
