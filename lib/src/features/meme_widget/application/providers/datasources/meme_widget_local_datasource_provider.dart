import 'package:memuno_app/src/features/meme_widget/data/datasources/home_widget_meme_widget_local_datasource_impl.dart';
import 'package:memuno_app/src/features/meme_widget/data/datasources/meme_widget_local_datasource.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_widget_local_datasource_provider.g.dart';

/// Provides the local datasource for meme widget operations.
@Riverpod(keepAlive: true)
MemeWidgetLocalDatasource memeWidgetLocalDatasource(Ref ref) {
  return const HomeWidgetMemeWidgetLocalDatasourceImpl();
}
