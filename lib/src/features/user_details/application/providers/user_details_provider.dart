import 'package:memuno_app/src/features/user_details/application/providers/usecases/get_user_details_usecase_provider.dart';
import 'package:memuno_app/src/features/user_details/domain/entities/user_details_entity.dart';
import 'package:memuno_app/src/features/user_details/domain/usecases/get_user_details_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_details_provider.g.dart';

/// Shared user-details state for one user id.
@Riverpod(keepAlive: true)
class UserDetails extends _$UserDetails {
  @override
  /// Loads one user's details.
  Future<UserDetailsEntity> build(String userId) async {
    final GetUserDetailsUsecase usecase = ref.watch(
      getUserDetailsUsecaseProvider,
    );
    return usecase(userId: userId);
  }

  /// Overrides the current state with an updated local name.
  void setName(String name) {
    final UserDetailsEntity? previous = state.asData?.value;
    if (previous == null) return;
    state = AsyncValue<UserDetailsEntity>.data(previous.copyWith(name: name));
  }
}
