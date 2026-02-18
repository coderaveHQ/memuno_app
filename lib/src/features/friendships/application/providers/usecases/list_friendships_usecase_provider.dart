import 'package:memuno_app/src/features/friendships/application/providers/friendships_repository_provider.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/list_friendships_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'list_friendships_usecase_provider.g.dart';

/// Provides [ListFriendshipsUsecase].
@riverpod
ListFriendshipsUsecase listFriendshipsUsecase(Ref ref) {
  final FriendshipsRepository repository = ref.watch(
    friendshipsRepositoryProvider,
  );
  return ListFriendshipsUsecase(repository: repository);
}
