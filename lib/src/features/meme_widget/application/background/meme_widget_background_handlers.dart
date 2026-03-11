import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/core/config/app_env.dart';
import 'package:memuno_app/src/core/failures/app_failure_mapper.dart';
import 'package:memuno_app/src/core/failures/supabase_failure_mapper.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/meme_widget/data/datasources/home_widget_meme_widget_local_datasource_impl.dart';
import 'package:memuno_app/src/features/meme_widget/data/datasources/supabase_meme_widget_remote_datasource_impl.dart';
import 'package:memuno_app/src/features/meme_widget/data/repositories/meme_widget_local_repository_impl.dart';
import 'package:memuno_app/src/features/meme_widget/data/repositories/meme_widget_remote_repository_impl.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_action_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_texts_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/handle_meme_widget_action_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/load_latest_meme_widget_items_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/set_meme_widget_selected_index_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/sync_meme_widget_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/toggle_meme_widget_laugh_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// HomeWidget interactivity callback entrypoint.
@pragma('vm:entry-point')
Future<void> memeWidgetInteractivityCallback(Uri? uri) async {
  if (uri == null) {
    return;
  }

  await _runSerializedBackgroundOperation(() async {
    final _BackgroundUsecaseBundle bundle =
        await _createBackgroundUsecaseBundle();
    final Locale locale = _resolveSystemLocale();
    final MemeWidgetTextsEntity texts = _resolveWidgetTexts(locale);

    final MemeWidgetActionEntity action = MemeWidgetActionEntity.fromUri(uri);

    if (action.type == MemeWidgetActionType.openApp ||
        action.type == MemeWidgetActionType.openMeme) {
      await bundle.localRepository.savePendingActionUri(uri.toString());
      return;
    }

    await bundle.handleActionUsecase(action: action, texts: texts);
  });
}

Future<void> _runSerializedBackgroundOperation(
  Future<void> Function() operation,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(options: AppEnv.firebaseOptions);
  } catch (_) {
    // Firebase may already be initialized in this isolate.
  }

  try {
    await operation();
  } catch (error, stackTrace) {
    Logger.instance.warn(
      message: 'Meme-widget background operation failed.',
      error: error,
      stackTrace: stackTrace,
    );
  }
}

Future<_BackgroundUsecaseBundle> _createBackgroundUsecaseBundle() async {
  final SupabaseClient supabaseClient = await _resolveSupabaseClient();

  final AppFailureMapper failureMapper = AppFailureMapper(
    supabaseFailureMapper: const SupabaseFailureMapper(),
  );

  final HomeWidgetMemeWidgetLocalDatasourceImpl localDatasource =
      const HomeWidgetMemeWidgetLocalDatasourceImpl();
  final SupabaseMemeWidgetRemoteDatasourceImpl remoteDatasource =
      SupabaseMemeWidgetRemoteDatasourceImpl(supabaseClient: supabaseClient);

  final MemeWidgetLocalRepository localRepository =
      MemeWidgetLocalRepositoryImpl(
        localDatasource: localDatasource,
        failureMapper: failureMapper,
      );

  final remoteRepository = MemeWidgetRemoteRepositoryImpl(
    remoteDatasource: remoteDatasource,
    failureMapper: failureMapper,
  );

  await localRepository.configure();

  final LoadLatestMemeWidgetItemsUsecase loadLatestUsecase =
      LoadLatestMemeWidgetItemsUsecase(repository: remoteRepository);
  final SyncMemeWidgetUsecase syncUsecase = SyncMemeWidgetUsecase(
    loadLatestItemsUsecase: loadLatestUsecase,
    localRepository: localRepository,
  );
  final ToggleMemeWidgetLaughUsecase toggleLaughUsecase =
      ToggleMemeWidgetLaughUsecase(repository: remoteRepository);
  final SetMemeWidgetSelectedIndexUsecase setSelectedIndexUsecase =
      SetMemeWidgetSelectedIndexUsecase(localRepository: localRepository);

  final HandleMemeWidgetActionUsecase handleActionUsecase =
      HandleMemeWidgetActionUsecase(
        syncUsecase: syncUsecase,
        toggleLaughUsecase: toggleLaughUsecase,
        setSelectedIndexUsecase: setSelectedIndexUsecase,
        localRepository: localRepository,
      );

  return _BackgroundUsecaseBundle(
    localRepository: localRepository,
    handleActionUsecase: handleActionUsecase,
  );
}

Future<SupabaseClient> _resolveSupabaseClient() async {
  try {
    return Supabase.instance.client;
  } catch (_) {
    await Supabase.initialize(
      url: AppEnv.secrets.supabaseUrl,
      anonKey: AppEnv.secrets.supabasePublishableKey,
    );
    return Supabase.instance.client;
  }
}

Locale _resolveSystemLocale() {
  final Locale locale = WidgetsBinding.instance.platformDispatcher.locale;

  if (locale.languageCode == 'de') {
    return const Locale('de', 'DE');
  }

  return const Locale('en', 'US');
}

MemeWidgetTextsEntity _resolveWidgetTexts(Locale locale) {
  final AppLocalizations l10n = lookupAppLocalizations(locale);
  return MemeWidgetTextsEntity(
    emptyText: l10n.widgetNoMemesYet,
    signedOutText: l10n.widgetSignInToDisplayMemes,
    laughActionText: l10n.widgetLaughAction,
    unlaughActionText: l10n.widgetUnlaughAction,
    ownerActionText: l10n.widgetOwnerAction,
  );
}

final class _BackgroundUsecaseBundle {
  const _BackgroundUsecaseBundle({
    required this.localRepository,
    required this.handleActionUsecase,
  });

  final MemeWidgetLocalRepository localRepository;
  final HandleMemeWidgetActionUsecase handleActionUsecase;
}
