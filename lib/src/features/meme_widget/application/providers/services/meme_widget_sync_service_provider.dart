import 'package:home_widget/home_widget.dart';
import 'package:memuno_app/src/core/providers/logger_provider.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/meme_widget/application/background/meme_widget_background_handlers.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/repositories/meme_widget_local_repository_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/usecases/apply_meme_widget_push_delta_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/usecases/clear_meme_widget_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/usecases/sync_meme_widget_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/services/meme_widget_sync_service.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/apply_meme_widget_push_delta_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/clear_meme_widget_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/sync_meme_widget_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_widget_sync_service_provider.g.dart';

/// Provides [MemeWidgetSyncService].
@Riverpod(keepAlive: true)
MemeWidgetSyncService memeWidgetSyncService(Ref ref) {
  final SyncMemeWidgetUsecase syncUsecase = ref.watch(
    syncMemeWidgetUsecaseProvider,
  );
  final ApplyMemeWidgetPushDeltaUsecase applyPushDeltaUsecase = ref.watch(
    applyMemeWidgetPushDeltaUsecaseProvider,
  );
  final ClearMemeWidgetUsecase clearUsecase = ref.watch(
    clearMemeWidgetUsecaseProvider,
  );
  final MemeWidgetLocalRepository localRepository = ref.watch(
    memeWidgetLocalRepositoryProvider,
  );
  final Logger logger = ref.watch(loggerProvider);

  return MemeWidgetSyncService(
    syncUsecase: syncUsecase,
    applyPushDeltaUsecase: applyPushDeltaUsecase,
    clearUsecase: clearUsecase,
    configureLocalStore: localRepository.configure,
    registerInteractivityCallback: () async {
      await HomeWidget.registerInteractivityCallback(
        memeWidgetInteractivityCallback,
      );
    },
    savePendingActionUri: localRepository.savePendingActionUri,
    takePendingActionUri: localRepository.takePendingActionUri,
    logger: logger,
  );
}
