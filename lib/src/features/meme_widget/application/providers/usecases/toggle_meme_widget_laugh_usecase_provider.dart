import 'package:memuno_app/src/features/meme_widget/application/providers/repositories/meme_widget_remote_repository_provider.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_remote_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/toggle_meme_widget_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_meme_widget_laugh_usecase_provider.g.dart';

/// Provides [ToggleMemeWidgetLaughUsecase].
@riverpod
ToggleMemeWidgetLaughUsecase toggleMemeWidgetLaughUsecase(Ref ref) {
  final MemeWidgetRemoteRepository repository = ref.watch(
    memeWidgetRemoteRepositoryProvider,
  );

  return ToggleMemeWidgetLaughUsecase(repository: repository);
}
