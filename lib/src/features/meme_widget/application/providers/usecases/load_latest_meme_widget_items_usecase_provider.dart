import 'package:memuno_app/src/features/meme_widget/application/providers/repositories/meme_widget_remote_repository_provider.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_remote_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/load_latest_meme_widget_items_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'load_latest_meme_widget_items_usecase_provider.g.dart';

/// Provides [LoadLatestMemeWidgetItemsUsecase].
@riverpod
LoadLatestMemeWidgetItemsUsecase loadLatestMemeWidgetItemsUsecase(Ref ref) {
  final MemeWidgetRemoteRepository repository = ref.watch(
    memeWidgetRemoteRepositoryProvider,
  );

  return LoadLatestMemeWidgetItemsUsecase(repository: repository);
}
