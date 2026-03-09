import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/features/auth/application/providers/current_user_provider.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/usecases/get_meme_details_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/usecases/toggle_meme_details_laugh_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_details_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/get_meme_details_usecase.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/toggle_meme_details_laugh_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_details_provider.g.dart';

/// Async controller for one meme details payload.
@Riverpod(keepAlive: true)
class MemeDetails extends _$MemeDetails
    with OptimisticAsyncStateMixin<MemeDetailsEntity> {
  @override
  /// Loads initial details state for one [memeId].
  Future<MemeDetailsEntity> build(String memeId) async {
    final GetMemeDetailsUsecase usecase = ref.watch(
      getMemeDetailsUsecaseProvider,
    );
    return usecase(memeId: memeId);
  }

  /// Refreshes current meme-details state.
  Future<void> refresh() async {
    final GetMemeDetailsUsecase usecase = ref.read(
      getMemeDetailsUsecaseProvider,
    );
    final MemeDetailsEntity details = await usecase(memeId: memeId);
    state = AsyncValue<MemeDetailsEntity>.data(details);
  }

  /// Toggles the current user's laugh state for this meme.
  Future<void> toggleMemeLaugh() async {
    final MemeDetailsEntity? current = state.asData?.value;
    if (current == null) {
      return;
    }

    final String? currentUserId = ref.read(currentUserProvider)?.id;
    if (currentUserId != null && current.user.id == currentUserId) {
      return;
    }

    final bool wasLaughed = current.isLaughed;
    final int previousCount = current.laughCount;
    final bool nextLaughed = !wasLaughed;
    final int nextCount = nextLaughed
        ? previousCount + 1
        : (previousCount - 1).clamp(0, previousCount).toInt();

    await runOptimisticUpdate<bool>(
      apply: (MemeDetailsEntity details) {
        return details.copyWith(isLaughed: nextLaughed, laughCount: nextCount);
      },
      rollback: (MemeDetailsEntity details) {
        return details.copyWith(
          isLaughed: wasLaughed,
          laughCount: previousCount,
        );
      },
      operation: () {
        final ToggleMemeDetailsLaughUsecase usecase = ref.read(
          toggleMemeDetailsLaughUsecaseProvider,
        );
        return usecase(memeId: memeId);
      },
    );
  }
}
