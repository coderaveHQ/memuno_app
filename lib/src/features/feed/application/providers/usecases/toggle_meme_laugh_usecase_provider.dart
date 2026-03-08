import 'package:memuno_app/src/features/feed/application/providers/feed_repository_provider.dart';
import 'package:memuno_app/src/features/feed/domain/repositories/feed_repository.dart';
import 'package:memuno_app/src/features/feed/domain/usecases/toggle_meme_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'toggle_meme_laugh_usecase_provider.g.dart';

/// Provides [ToggleMemeLaughUsecase].
@riverpod
ToggleMemeLaughUsecase toggleMemeLaughUsecase(Ref ref) {
  final FeedRepository repository = ref.watch(feedRepositoryProvider);
  return ToggleMemeLaughUsecase(repository: repository);
}
