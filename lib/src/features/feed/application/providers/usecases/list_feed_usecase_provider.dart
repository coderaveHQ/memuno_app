import 'package:memuno_app/src/features/feed/application/providers/feed_repository_provider.dart';
import 'package:memuno_app/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:memuno_app/src/features/feed/domain/usecases/list_feed_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_feed_usecase_provider.g.dart';

/// Provides [ListFeedUsecase].
@riverpod
ListFeedUsecase listFeedUsecase(Ref ref) {
  final FeedRepository repository = ref.watch(feedRepositoryProvider);
  return ListFeedUsecase(repository: repository);
}
