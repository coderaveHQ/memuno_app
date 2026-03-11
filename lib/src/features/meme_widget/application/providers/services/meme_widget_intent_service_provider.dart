import 'package:go_router/go_router.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/settings/language_resolution_provider.dart';
import 'package:memuno_app/src/core/providers/logger_provider.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/repositories/meme_widget_local_repository_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/usecases/handle_meme_widget_action_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/services/meme_widget_intent_service.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/handle_meme_widget_action_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_widget_intent_service_provider.g.dart';

/// Provides [MemeWidgetIntentService].
@Riverpod(keepAlive: true)
MemeWidgetIntentService memeWidgetIntentService(Ref ref) {
  final MemeWidgetLocalRepository localRepository = ref.watch(
    memeWidgetLocalRepositoryProvider,
  );
  final HandleMemeWidgetActionUsecase handleActionUsecase = ref.watch(
    handleMemeWidgetActionUsecaseProvider,
  );
  final GoRouter router = ref.watch(appRouterProvider);
  final Logger logger = ref.watch(loggerProvider);

  final MemeWidgetIntentService service = MemeWidgetIntentService(
    localRepository: localRepository,
    handleActionUsecase: handleActionUsecase,
    router: router,
    resolveLocale: () {
      return ref.read(languageResolutionProvider).resolvedLocale;
    },
    logger: logger,
  );

  ref.onDispose(service.dispose);
  return service;
}
