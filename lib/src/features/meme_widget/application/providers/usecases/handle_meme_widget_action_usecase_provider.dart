import 'package:memuno_app/src/features/meme_widget/application/providers/repositories/meme_widget_local_repository_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/usecases/set_meme_widget_selected_index_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/usecases/sync_meme_widget_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/usecases/toggle_meme_widget_laugh_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/handle_meme_widget_action_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/set_meme_widget_selected_index_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/sync_meme_widget_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/toggle_meme_widget_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'handle_meme_widget_action_usecase_provider.g.dart';

/// Provides [HandleMemeWidgetActionUsecase].
@riverpod
HandleMemeWidgetActionUsecase handleMemeWidgetActionUsecase(Ref ref) {
  final SyncMemeWidgetUsecase syncUsecase = ref.watch(
    syncMemeWidgetUsecaseProvider,
  );
  final ToggleMemeWidgetLaughUsecase toggleLaughUsecase = ref.watch(
    toggleMemeWidgetLaughUsecaseProvider,
  );
  final SetMemeWidgetSelectedIndexUsecase setSelectedIndexUsecase = ref.watch(
    setMemeWidgetSelectedIndexUsecaseProvider,
  );
  final MemeWidgetLocalRepository localRepository = ref.watch(
    memeWidgetLocalRepositoryProvider,
  );

  return HandleMemeWidgetActionUsecase(
    syncUsecase: syncUsecase,
    toggleLaughUsecase: toggleLaughUsecase,
    setSelectedIndexUsecase: setSelectedIndexUsecase,
    localRepository: localRepository,
  );
}
