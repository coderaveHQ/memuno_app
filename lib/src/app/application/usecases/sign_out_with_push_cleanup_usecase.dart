import 'package:flutter/widgets.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:memuno_app/src/features/meme_widget/domain/entities/meme_widget_texts_entity.dart';
import 'package:memuno_app/src/features/meme_widget/domain/usecases/clear_meme_widget_usecase.dart';
import 'package:memuno_app/src/features/push_notifications/domain/entities/push_token_deactivation_reason.dart';
import 'package:memuno_app/src/features/push_notifications/domain/usecases/deactivate_current_device_push_token_usecase.dart';

/// App-level sign-out orchestration:
/// 1) best-effort push token deactivation
/// 2) auth sign-out
final class SignOutWithPushCleanupUsecase {
  /// Creates the usecase.
  const SignOutWithPushCleanupUsecase({
    required SignOutUsecase signOutUsecase,
    required DeactivateCurrentDevicePushTokenUsecase
    deactivateCurrentDevicePushTokenUsecase,
    required ClearMemeWidgetUsecase clearMemeWidgetUsecase,
    required Locale Function() resolveLocale,
    required Logger logger,
  }) : _signOutUsecase = signOutUsecase,
       _deactivateCurrentDevicePushTokenUsecase =
           deactivateCurrentDevicePushTokenUsecase,
       _clearMemeWidgetUsecase = clearMemeWidgetUsecase,
       _resolveLocale = resolveLocale,
       _logger = logger;

  final SignOutUsecase _signOutUsecase;
  final DeactivateCurrentDevicePushTokenUsecase
  _deactivateCurrentDevicePushTokenUsecase;
  final ClearMemeWidgetUsecase _clearMemeWidgetUsecase;
  final Locale Function() _resolveLocale;
  final Logger _logger;

  /// Executes sign-out with best-effort push cleanup.
  Future<void> call() async {
    try {
      final AppLocalizations l10n = lookupAppLocalizations(_resolveLocale());
      await _clearMemeWidgetUsecase(
        texts: MemeWidgetTextsEntity(
          emptyText: l10n.widgetNoMemesYet,
          signedOutText: l10n.widgetSignInToDisplayMemes,
          laughActionText: l10n.widgetLaughAction,
          unlaughActionText: l10n.widgetUnlaughAction,
          ownerActionText: l10n.widgetOwnerAction,
        ),
      );
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to clear widget state before sign-out.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    try {
      await _deactivateCurrentDevicePushTokenUsecase(
        reason: PushTokenDeactivationReason.signedOut,
      );
    } catch (error, stackTrace) {
      _logger.warn(
        message: 'Failed to deactivate push token before sign-out.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    await _signOutUsecase();
  }
}
