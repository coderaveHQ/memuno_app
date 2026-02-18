import 'package:memuno_app/src/features/friendships/application/providers/friendships_repository_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/accept_friendship_request_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'accept_friendship_request_usecase_provider.g.dart';

/// Provides [AcceptFriendshipRequestUsecase].
@riverpod
AcceptFriendshipRequestUsecase acceptFriendshipRequestUsecase(Ref ref) {
  final FriendshipsRepository repository = ref.watch(
    friendshipsRepositoryProvider,
  );
  return AcceptFriendshipRequestUsecase(repository: repository);
}
