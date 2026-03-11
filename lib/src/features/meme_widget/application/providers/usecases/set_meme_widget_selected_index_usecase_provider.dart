import 'package:memuno_app/src/features/meme_widget/application/providers/repositories/meme_widget_local_repository_provider.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/set_meme_widget_selected_index_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'set_meme_widget_selected_index_usecase_provider.g.dart';

/// Provides [SetMemeWidgetSelectedIndexUsecase].
@riverpod
SetMemeWidgetSelectedIndexUsecase setMemeWidgetSelectedIndexUsecase(Ref ref) {
  final MemeWidgetLocalRepository localRepository = ref.watch(
    memeWidgetLocalRepositoryProvider,
  );

  return SetMemeWidgetSelectedIndexUsecase(localRepository: localRepository);
}
