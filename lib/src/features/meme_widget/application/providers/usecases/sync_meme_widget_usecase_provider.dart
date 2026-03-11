import 'package:memuno_app/src/features/meme_widget/application/providers/repositories/meme_widget_local_repository_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/usecases/load_latest_meme_widget_items_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/load_latest_meme_widget_items_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/sync_meme_widget_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_meme_widget_usecase_provider.g.dart';

/// Provides [SyncMemeWidgetUsecase].
@riverpod
SyncMemeWidgetUsecase syncMemeWidgetUsecase(Ref ref) {
  final LoadLatestMemeWidgetItemsUsecase loadLatestItemsUsecase = ref.watch(
    loadLatestMemeWidgetItemsUsecaseProvider,
  );
  final MemeWidgetLocalRepository localRepository = ref.watch(
    memeWidgetLocalRepositoryProvider,
  );

  return SyncMemeWidgetUsecase(
    loadLatestItemsUsecase: loadLatestItemsUsecase,
    localRepository: localRepository,
  );
}
