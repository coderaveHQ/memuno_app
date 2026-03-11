import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_item_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_remote_repository.dart';

/// Usecase for loading the most recent widget meme items.
final class LoadLatestMemeWidgetItemsUsecase {
  /// Creates the usecase.
  const LoadLatestMemeWidgetItemsUsecase({
    required MemeWidgetRemoteRepository repository,
  }) : _repository = repository;

  final MemeWidgetRemoteRepository _repository;

  /// Loads the latest [limit] items.
  Future<List<MemeWidgetItemEntity>> call({required int limit}) {
    return _repository.loadLatestItems(limit: limit);
  }
}
