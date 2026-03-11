import 'package:memuno_app/src/features/meme_widget/application/providers/repositories/meme_widget_local_repository_provider.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/clear_meme_widget_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clear_meme_widget_usecase_provider.g.dart';

/// Provides [ClearMemeWidgetUsecase].
@riverpod
ClearMemeWidgetUsecase clearMemeWidgetUsecase(Ref ref) {
  final MemeWidgetLocalRepository localRepository = ref.watch(
    memeWidgetLocalRepositoryProvider,
  );

  return ClearMemeWidgetUsecase(localRepository: localRepository);
}
