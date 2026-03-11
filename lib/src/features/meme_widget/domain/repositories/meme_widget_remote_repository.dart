import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_item_entity.dart';

/// Repository contract for remote widget data operations.
abstract interface class MemeWidgetRemoteRepository {
  /// Loads up to [limit] most recent feed memes for widget rendering.
  Future<List<MemeWidgetItemEntity>> loadLatestItems({required int limit});

  /// Toggles laugh state for meme [memeId] and returns resulting state.
  Future<bool> toggleMemeLaugh({required String memeId});
}
