import 'package:memuno_app/src/features/meme_templates/application/providers/meme_templates_repository_provider.dart';
import 'package:memuno_app/src/features/meme_templates/domain/repositories/meme_templates_repository.dart';
import 'package:memuno_app/src/features/meme_templates/domain/usecases/list_meme_templates_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_meme_templates_usecase_provider.g.dart';

/// Provides [ListMemeTemplatesUsecase].
@riverpod
ListMemeTemplatesUsecase listMemeTemplatesUsecase(Ref ref) {
  final MemeTemplatesRepository repository = ref.watch(
    memeTemplatesRepositoryProvider,
  );
  return ListMemeTemplatesUsecase(repository: repository);
}
