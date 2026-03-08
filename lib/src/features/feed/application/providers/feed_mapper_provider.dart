import 'package:memuno_app/src/features/feed/data/mappers/feed_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feed_mapper_provider.g.dart';

/// Provides [FeedMapper].
@Riverpod(keepAlive: true)
FeedMapper feedMapper(Ref ref) {
  return const FeedMapper();
}
