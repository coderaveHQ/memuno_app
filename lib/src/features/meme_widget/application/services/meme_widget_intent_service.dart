import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_action_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_texts_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/repositories/meme_widget_local_repository.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/handle_meme_widget_action_usecase.dart';

/// Handles widget click intents and routes them into app actions/navigation.
final class MemeWidgetIntentService {
  /// Creates the service.
  MemeWidgetIntentService({
    required MemeWidgetLocalRepository localRepository,
    required HandleMemeWidgetActionUsecase handleActionUsecase,
    required GoRouter router,
    required Locale Function() resolveLocale,
    required Logger logger,
  }) : _localRepository = localRepository,
       _handleActionUsecase = handleActionUsecase,
       _router = router,
       _resolveLocale = resolveLocale,
       _logger = logger;

  final MemeWidgetLocalRepository _localRepository;
  final HandleMemeWidgetActionUsecase _handleActionUsecase;
  final GoRouter _router;
  final Locale Function() _resolveLocale;
  final Logger _logger;

  StreamSubscription<Uri>? _widgetClickSubscription;
  bool _isInitialized = false;
  String? _currentUserId;

  /// Initializes click stream handling and initial-launch intent processing.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    _widgetClickSubscription = _localRepository.widgetClickedStream().listen(
      (Uri uri) {
        unawaited(_handleUri(uri));
      },
      onError: (Object error, StackTrace stackTrace) {
        _logger.warn(
          message: 'Meme-widget click stream failed.',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    try {
      final Uri? initialUri = await _localRepository.initiallyLaunchedUri();
      if (initialUri != null) {
        await _handleUri(initialUri);
      }
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to resolve initial meme-widget launch URI.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    _isInitialized = true;
  }

  /// Updates auth user id used for guarded navigation decisions.
  void handleAuthStateChange({required String? userId}) {
    _currentUserId = userId;
  }

  /// Handles a deferred action URI stored by background callbacks.
  Future<void> handlePendingActionUri(String actionUri) async {
    try {
      final Uri uri = Uri.parse(actionUri);
      await _handleUri(uri);
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to handle deferred meme-widget action URI.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Releases stream resources.
  Future<void> dispose() async {
    await _widgetClickSubscription?.cancel();
  }

  Future<void> _handleUri(Uri uri) async {
    try {
      final MemeWidgetActionEntity action = MemeWidgetActionEntity.fromUri(uri);
      final MemeWidgetTextsEntity texts = _resolveTexts();
      final MemeWidgetActionResult result = await _handleActionUsecase(
        action: action,
        texts: texts,
      );

      if (result.openMemeId != null && result.openMemeId!.isNotEmpty) {
        if (_currentUserId == null) {
          _router.go(const SignInRoute().location);
          return;
        }

        await _router.push(
          MemeDetailsRoute(memeId: result.openMemeId!).location,
        );
        return;
      }

      if (result.shouldOpenApp) {
        if (_currentUserId == null) {
          _router.go(const SignInRoute().location);
        } else {
          _router.go(const FeedRoute().location);
        }
      }
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to process meme-widget URI action.',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  MemeWidgetTextsEntity _resolveTexts() {
    final AppLocalizations l10n = lookupAppLocalizations(_resolveLocale());
    return MemeWidgetTextsEntity(
      emptyText: l10n.widgetNoMemesYet,
      signedOutText: l10n.widgetSignInToDisplayMemes,
      laughActionText: l10n.widgetLaughAction,
      unlaughActionText: l10n.widgetUnlaughAction,
      ownerActionText: l10n.widgetOwnerAction,
    );
  }
}
