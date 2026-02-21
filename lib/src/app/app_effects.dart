import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/feedback/app_feedback.dart';
import 'package:memuno_app/src/app/feedback/app_feedback_provider.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_state_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:memuno_app/src/features/deep_links/application/providers/incoming_deep_link_provider.dart';
import 'package:memuno_app/src/features/deep_links/presentation/providers/deep_link_navigation_handler_provider.dart';

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

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
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
      _handleAuthState(context, previous?.asData?.value, nextState);
    });

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
}
