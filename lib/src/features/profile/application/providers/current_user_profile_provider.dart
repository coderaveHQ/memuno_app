import 'package:memuno_app/src/features/profile/application/providers/usecases/get_current_user_profile_usecase_provider.dart';
import 'package:memuno_app/src/features/profile/domain/entities/user_profile_entity.dart';
import 'package:memuno_app/src/features/profile/domain/usecases/get_current_user_profile_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_profile_provider.g.dart';

/// Shared current-user profile state.
@Riverpod(keepAlive: true)
class CurrentUserProfile extends _$CurrentUserProfile {
  @override
  /// Loads the current user's profile.
  Future<UserProfileEntity> build() async {
    final GetCurrentUserProfileUsecase usecase = ref.watch(
      getCurrentUserProfileUsecaseProvider,
    );
    return usecase();
  }

  /// Overrides the current state with an updated local name.
  void setName(String name) {
    final UserProfileEntity? previous = state.asData?.value;
    if (previous == null) return;
    state = AsyncValue<UserProfileEntity>.data(previous.copyWith(name: name));
  }
}
