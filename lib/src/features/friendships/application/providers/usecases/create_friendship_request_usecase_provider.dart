import 'package:memuno_app/src/features/friendships/application/providers/friendships_repository_provider.dart';
import 'package:memuno_app/src/core/providers/validator_provider.dart';
import 'package:memuno_app/src/core/validation/validator.dart';
import 'package:memuno_app/src/features/friendships/domain/repositories/friendships_repository.dart';
import 'package:memuno_app/src/features/friendships/domain/usecases/create_friendship_request_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_friendship_request_usecase_provider.g.dart';

/// Provides [CreateFriendshipRequestUsecase].
@riverpod
CreateFriendshipRequestUsecase createFriendshipRequestUsecase(Ref ref) {
  final FriendshipsRepository repository = ref.watch(
    friendshipsRepositoryProvider,
  );
  final Validator validator = ref.watch(validatorProvider);
  return CreateFriendshipRequestUsecase(
    repository: repository,
    validator: validator,
  );
}
