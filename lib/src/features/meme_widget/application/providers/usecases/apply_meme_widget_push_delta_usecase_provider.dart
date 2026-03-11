import 'package:memuno_app/src/features/meme_widget/application/providers/repositories/meme_widget_local_repository_provider.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/apply_meme_widget_push_delta_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'apply_meme_widget_push_delta_usecase_provider.g.dart';

/// Provides [ApplyMemeWidgetPushDeltaUsecase].
@riverpod
ApplyMemeWidgetPushDeltaUsecase applyMemeWidgetPushDeltaUsecase(Ref ref) {
  final MemeWidgetLocalRepository localRepository = ref.watch(
    memeWidgetLocalRepositoryProvider,
  );

  return ApplyMemeWidgetPushDeltaUsecase(localRepository: localRepository);
}
