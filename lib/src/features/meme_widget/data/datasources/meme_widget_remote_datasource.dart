import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_item_entity.dart';

/// Low-level datasource for remote widget data.
abstract interface class MemeWidgetRemoteDatasource {
  /// Loads latest [limit] widget-capable meme items from backend.
  Future<List<MemeWidgetItemEntity>> loadLatestItems({required int limit});

  /// Toggles laugh state for [memeId] and returns resulting state.
  Future<bool> toggleMemeLaugh({required String memeId});
}
