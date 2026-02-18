import 'package:memuno_app/src/features/friendships/application/providers/friendships_repository_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/delete_friendship_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_friendship_usecase_provider.g.dart';

/// Provides [DeleteFriendshipUsecase].
@riverpod
DeleteFriendshipUsecase deleteFriendshipUsecase(Ref ref) {
  final FriendshipsRepository repository = ref.watch(
    friendshipsRepositoryProvider,
  );
  return DeleteFriendshipUsecase(repository: repository);
}
