import 'package:flutter/widgets.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_push_delta_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_texts_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/apply_meme_widget_push_delta_usecase.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/clear_meme_widget_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/sync_meme_widget_usecase.dart';

/// App-level service for widget synchronization lifecycle.
final class MemeWidgetSyncService {
  /// Creates the service.
  MemeWidgetSyncService({
    required SyncMemeWidgetUsecase syncUsecase,
    required ApplyMemeWidgetPushDeltaUsecase applyPushDeltaUsecase,
    required ClearMemeWidgetUsecase clearUsecase,
    required Future<void> Function() configureLocalStore,
    required Future<void> Function() registerInteractivityCallback,
    required Future<void> Function(String actionUri) savePendingActionUri,
    required Future<String?> Function() takePendingActionUri,
    required Logger logger,
  }) : _syncUsecase = syncUsecase,
       _applyPushDeltaUsecase = applyPushDeltaUsecase,
       _clearUsecase = clearUsecase,
       _configureLocalStore = configureLocalStore,
       _registerInteractivityCallback = registerInteractivityCallback,
       _savePendingActionUri = savePendingActionUri,
       _takePendingActionUri = takePendingActionUri,
       _logger = logger;

  final SyncMemeWidgetUsecase _syncUsecase;
  final ApplyMemeWidgetPushDeltaUsecase _applyPushDeltaUsecase;
  final ClearMemeWidgetUsecase _clearUsecase;
  final Future<void> Function() _configureLocalStore;

  /// Re-registers the HomeWidget interactivity callback for startup hardening.
  final Future<void> Function() _registerInteractivityCallback;
  final Future<void> Function(String actionUri) _savePendingActionUri;
  final Future<String?> Function() _takePendingActionUri;
  final Logger _logger;

  bool _isInitialized = false;

  /// Initializes shared widget storage integration.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      await _configureLocalStore();
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to initialize meme-widget sync service.',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    try {
      await _registerInteractivityCallback();
    } catch (error, stackTrace) {
      _logger.warn(
        message:
            'Failed to register HomeWidget interactivity callback during meme-widget service initialization.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    _isInitialized = true;
  }

  /// Syncs widget contents for authenticated state.
  Future<void> sync({required Locale locale}) async {
    final MemeWidgetTextsEntity texts = _resolveTexts(locale);
    try {
      await _syncUsecase(texts: texts);
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to sync meme widget snapshot.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Applies push-enriched payload and falls back to full sync when necessary.
  Future<void> applyPushData({
    required Map<String, String> data,
    required Locale locale,
  }) async {
    final MemeWidgetTextsEntity texts = _resolveTexts(locale);
    try {
      final MemeWidgetPushDeltaEntity delta =
          MemeWidgetPushDeltaEntity.fromPushData(data);
      final ApplyMemeWidgetPushDeltaResult result =
          await _applyPushDeltaUsecase(delta: delta, texts: texts);

      if (!result.didApply && result.requiresSyncFallback) {
        await _syncUsecase(texts: texts);
      }
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to apply push delta for meme widget snapshot.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Clears widget contents for signed-out state.
  Future<void> clear({required Locale locale}) async {
    final MemeWidgetTextsEntity texts = _resolveTexts(locale);
    try {
      await _clearUsecase(texts: texts);
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to clear meme widget snapshot.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Syncs widget according to current auth [userId].
  Future<void> syncForAuthState({
    required String? userId,
    required Locale locale,
  }) {
    if (userId == null) {
      return clear(locale: locale);
    }

    return sync(locale: locale);
  }

  /// Stores deferred action URI for later handling.
  Future<void> savePendingActionUri(String actionUri) async {
    try {
      await _savePendingActionUri(actionUri);
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to save pending meme-widget action.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Reads and clears deferred action URI.
  Future<String?> takePendingActionUri() async {
    try {
      return await _takePendingActionUri();
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to load pending meme-widget action.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  MemeWidgetTextsEntity _resolveTexts(Locale locale) {
    final AppLocalizations l10n = lookupAppLocalizations(locale);
    return MemeWidgetTextsEntity(
      emptyText: l10n.widgetNoMemesYet,
      signedOutText: l10n.widgetSignInToDisplayMemes,
      laughActionText: l10n.widgetLaughAction,
      unlaughActionText: l10n.widgetUnlaughAction,
      ownerActionText: l10n.widgetOwnerAction,
    );
  }
}
