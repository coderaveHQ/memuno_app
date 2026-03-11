import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/app/settings/language_resolution_provider.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_state_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:memuno_app/src/features/deep_links/application/providers/incoming_deep_link_provider.dart';
import 'package:memuno_app/src/features/deep_links/presentation/providers/deep_link_navigation_handler_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/services/meme_widget_intent_service_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/providers/services/meme_widget_sync_service_provider.dart';
import 'package:memuno_app/src/features/meme_widget/application/services/meme_widget_intent_service.dart';
import 'package:memuno_app/src/features/meme_widget/application/services/meme_widget_sync_service.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notifications_badge_sync_provider.dart';
import 'package:memuno_app/src/features/notifications/application/providers/notifications_realtime_sync_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/entities/push_auth_lifecycle_event.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_notifications_intent_service_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/services/push_notifications_intent_service.dart';
import 'package:memuno_app/src/features/push_notifications/application/providers/push_notifications_lifecycle_service_provider.dart';
import 'package:memuno_app/src/features/push_notifications/application/services/push_notifications_lifecycle_service.dart';

/// App-level side effects that react to global state changes.
final class AppEffects extends ConsumerStatefulWidget {
  /// Creates the app effects wrapper.
  const AppEffects({super.key, required this.child});

  /// Child subtree rendered beneath the effects layer.
  final Widget child;

  @override
  /// Creates the state object for this widget.
  ConsumerState<AppEffects> createState() => _AppEffectsState();
}

class _AppEffectsState extends ConsumerState<AppEffects> {
  // Holds the email that triggered an email-change toast so we can suppress
  // a follow-up signed-in toast for the same change.
  String? _pendingEmailChangeEmail;
  AuthStateEntity? _lastHandledAuthState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final PushNotificationsLifecycleService lifecycleService = ref.read(
        pushNotificationsLifecycleServiceProvider,
      );
      final PushNotificationsIntentService intentService = ref.read(
        pushNotificationsIntentServiceProvider,
      );
      final MemeWidgetSyncService memeWidgetSyncService = ref.read(
        memeWidgetSyncServiceProvider,
      );
      final MemeWidgetIntentService memeWidgetIntentService = ref.read(
        memeWidgetIntentServiceProvider,
      );
      unawaited(lifecycleService.initialize());
      unawaited(intentService.initialize());
      unawaited(memeWidgetSyncService.initialize());
      unawaited(memeWidgetIntentService.initialize());

      // App-global listeners that keep unread count + app-icon badge in sync.
      ref.read(notificationsRealtimeSyncProvider);
      ref.read(notificationsBadgeSyncProvider);

      final LanguageResolution languageResolution = ref.read(
        languageResolutionProvider,
      );
      lifecycleService.handleResolvedLocale(languageResolution.resolvedLocale);

      final AuthStateEntity? initialAuthState = ref
          .read(authStateProvider)
          .asData
          ?.value;
      if (initialAuthState != null) {
        _lastHandledAuthState = initialAuthState;
        _emitPushAuthIntent(
          lifecycleService: lifecycleService,
          state: initialAuthState,
        );
        _emitPushIntentAuthState(
          intentService: intentService,
          state: initialAuthState,
        );
        memeWidgetIntentService.handleAuthStateChange(
          userId: initialAuthState.user?.id,
        );
        unawaited(
          memeWidgetSyncService.syncForAuthState(
            userId: initialAuthState.user?.id,
            locale: languageResolution.resolvedLocale,
          ),
        );
        unawaited(
          _drainPendingMemeWidgetAction(
            syncService: memeWidgetSyncService,
            intentService: memeWidgetIntentService,
          ),
        );
      }
    });
  }

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    ref.listen<LanguageResolution>(languageResolutionProvider, (
      LanguageResolution? previous,
      LanguageResolution next,
    ) {
      final PushNotificationsLifecycleService lifecycleService = ref.read(
        pushNotificationsLifecycleServiceProvider,
      );
      lifecycleService.handleResolvedLocale(next.resolvedLocale);

      final MemeWidgetSyncService memeWidgetSyncService = ref.read(
        memeWidgetSyncServiceProvider,
      );
      final AuthStateEntity? state = ref.read(authStateProvider).asData?.value;
      if (state != null) {
        unawaited(
          memeWidgetSyncService.syncForAuthState(
            userId: state.user?.id,
            locale: next.resolvedLocale,
          ),
        );
      }
    });

    // Listen to external deep links and route them through the central handler.
    ref.listen<AsyncValue<Uri>>(incomingDeepLinkProvider, (
      AsyncValue<Uri>? previous,
      AsyncValue<Uri> next,
    ) {
      if (!context.mounted) return;

      final Uri? uri = next.asData?.value;
      if (uri == null) {
        return;
      }
      final Uri? previousUri = previous?.asData?.value;
      if (previousUri == uri) {
        return;
      }

      _handleIncomingDeepLink(uri);
    });

    // Listen to auth state changes and emit UI side effects (toasts).
    ref.listen<AsyncValue<AuthStateEntity>>(authStateProvider, (
      AsyncValue<AuthStateEntity>? previous,
      AsyncValue<AuthStateEntity> next,
    ) {
      // Avoid side effects after the widget is disposed.
      if (!context.mounted) return;
      // Only act on concrete auth states; ignore loading/error.
      final AuthStateEntity? nextState = next.asData?.value;
      if (nextState == null) {
        return;
      }

      final PushNotificationsLifecycleService lifecycleService = ref.read(
        pushNotificationsLifecycleServiceProvider,
      );
      final PushNotificationsIntentService intentService = ref.read(
        pushNotificationsIntentServiceProvider,
      );
      final MemeWidgetSyncService memeWidgetSyncService = ref.read(
        memeWidgetSyncServiceProvider,
      );
      final MemeWidgetIntentService memeWidgetIntentService = ref.read(
        memeWidgetIntentServiceProvider,
      );
      _lastHandledAuthState = nextState;
      _emitPushAuthIntent(lifecycleService: lifecycleService, state: nextState);
      _emitPushIntentAuthState(intentService: intentService, state: nextState);
      memeWidgetIntentService.handleAuthStateChange(userId: nextState.user?.id);
      final LanguageResolution languageResolution = ref.read(
        languageResolutionProvider,
      );
      unawaited(
        memeWidgetSyncService.syncForAuthState(
          userId: nextState.user?.id,
          locale: languageResolution.resolvedLocale,
        ),
      );
      unawaited(
        _drainPendingMemeWidgetAction(
          syncService: memeWidgetSyncService,
          intentService: memeWidgetIntentService,
        ),
      );
      _handleAuthState(context, previous?.asData?.value, nextState);
    });

    // If auth state is already available from another subscriber, process it
    // once to avoid missing startup/session-restore sync.
    final AuthStateEntity? cachedAuthState = ref
        .read(authStateProvider)
        .asData
        ?.value;
    if (cachedAuthState != null && cachedAuthState != _lastHandledAuthState) {
      final PushNotificationsLifecycleService lifecycleService = ref.read(
        pushNotificationsLifecycleServiceProvider,
      );
      final PushNotificationsIntentService intentService = ref.read(
        pushNotificationsIntentServiceProvider,
      );
      final MemeWidgetIntentService memeWidgetIntentService = ref.read(
        memeWidgetIntentServiceProvider,
      );
      final MemeWidgetSyncService memeWidgetSyncService = ref.read(
        memeWidgetSyncServiceProvider,
      );
      _lastHandledAuthState = cachedAuthState;
      _emitPushAuthIntent(
        lifecycleService: lifecycleService,
        state: cachedAuthState,
      );
      _emitPushIntentAuthState(
        intentService: intentService,
        state: cachedAuthState,
      );
      memeWidgetIntentService.handleAuthStateChange(
        userId: cachedAuthState.user?.id,
      );
      final LanguageResolution languageResolution = ref.read(
        languageResolutionProvider,
      );
      unawaited(
        memeWidgetSyncService.syncForAuthState(
          userId: cachedAuthState.user?.id,
          locale: languageResolution.resolvedLocale,
        ),
      );
      unawaited(
        _drainPendingMemeWidgetAction(
          syncService: memeWidgetSyncService,
          intentService: memeWidgetIntentService,
        ),
      );
    }

    // Render the subtree unchanged; effects are handled via the listener.
    return widget.child;
  }

  // Map auth lifecycle events to user-facing success toasts.
  void _handleAuthState(
    BuildContext context,
    AuthStateEntity? previous,
    AuthStateEntity next,
  ) {
    final BuildContext? toastContext = _resolveToastContext();
    if (toastContext == null) {
      return;
    }
    // Use the centralized feedback helper for consistent styling and i18n.
    final AppFeedback feedback = ref.read(appFeedbackProvider);
    final AppLocalizations l10n = AppLocalizations.of(toastContext);

    // Compare emails to detect a genuine email change.
    final String? previousEmail = previous?.user?.email;
    final String? nextEmail = next.user?.email;
    final bool emailChanged =
        previousEmail != null &&
        nextEmail != null &&
        previousEmail != nextEmail;

    switch (next.event) {
      case AuthEvent.signedIn:
        // Ignore sign-in events that don't carry a user.
        if (next.user == null) {
          return;
        }
        // Suppress the "signed in" toast on app startup when restoring
        // an existing session (initial -> signedIn for the same user).
        if (previous?.event == AuthEvent.initial &&
            previous?.user?.id == next.user?.id) {
          return;
        }
        // If we just handled an email change, skip the generic sign-in toast.
        if (_pendingEmailChangeEmail != null &&
            nextEmail == _pendingEmailChangeEmail) {
          _pendingEmailChangeEmail = null;
          return;
        }
        // Clear any stale pending email change before showing a toast.
        _pendingEmailChangeEmail = null;
        if (emailChanged) {
          feedback.showSuccess(
            toastContext,
            message: l10n.authToastEmailChangedMessage,
          );
          return;
        }
        // Default sign-in toast.
        feedback.showSuccess(
          toastContext,
          message: l10n.authToastSignedInMessage,
        );
        return;
      case AuthEvent.signedOut:
        // Reset pending email change on sign-out.
        _pendingEmailChangeEmail = null;
        // If there was no previous user, don't show a sign-out toast.
        if (previous?.user == null) {
          return;
        }
        feedback.showSuccess(
          toastContext,
          message: l10n.authToastSignedOutMessage,
        );
        return;
      case AuthEvent.passwordRecovery:
        // Password recovery indicates the user can now set a new password.
        _pendingEmailChangeEmail = null;
        feedback.showSuccess(
          toastContext,
          message: l10n.authToastPasswordRecoveryMessage,
        );
        return;
      case AuthEvent.userUpdated:
        // userUpdated is fired for profile updates; show email-change only.
        if (emailChanged) {
          // Store the email so a following signed-in event doesn't double-toast.
          _pendingEmailChangeEmail = nextEmail;
          feedback.showSuccess(
            toastContext,
            message: l10n.authToastEmailChangedMessage,
          );
        }
        return;
      case AuthEvent.initial:
      case AuthEvent.tokenRefreshed:
      case AuthEvent.unknown:
        // No user-facing toast for these events.
        return;
    }
  }

  /// Routes an incoming external [uri] through the central deep-link handler.
  void _handleIncomingDeepLink(Uri uri) {
    final DeepLinkNavigationHandler handler = ref.read(
      deepLinkNavigationHandlerProvider,
    );
    handler(uri);
  }

  void _emitPushAuthIntent({
    required PushNotificationsLifecycleService lifecycleService,
    required AuthStateEntity state,
  }) {
    final PushAuthLifecycleEvent? event = _toPushAuthLifecycleEvent(state);
    if (event == null) {
      return;
    }

    lifecycleService.handleAuthStateChange(
      event: event,
      userId: state.user?.id,
    );
  }

  void _emitPushIntentAuthState({
    required PushNotificationsIntentService intentService,
    required AuthStateEntity state,
  }) {
    intentService.handleAuthStateChange(userId: state.user?.id);
  }

  PushAuthLifecycleEvent? _toPushAuthLifecycleEvent(AuthStateEntity state) {
    if (state.event == AuthEvent.signedOut) {
      return PushAuthLifecycleEvent.sessionEnded;
    }
    if (state.user != null) {
      return PushAuthLifecycleEvent.sessionAvailable;
    }
    return null;
  }

  /// Resolves an overlay context that can host toast notifications.
  BuildContext? _resolveToastContext() {
    final NavigatorState? navigatorState = rootNavigatorKey.currentState;
    if (navigatorState == null) {
      return null;
    }
    final OverlayState? overlay = navigatorState.overlay;
    if (overlay == null || !overlay.mounted) {
      return null;
    }
    return overlay.context;
  }

  Future<void> _drainPendingMemeWidgetAction({
    required MemeWidgetSyncService syncService,
    required MemeWidgetIntentService intentService,
  }) async {
    final String? actionUri = await syncService.takePendingActionUri();
    if (actionUri == null || actionUri.trim().isEmpty) {
      return;
    }

    await intentService.handlePendingActionUri(actionUri);
  }
}
