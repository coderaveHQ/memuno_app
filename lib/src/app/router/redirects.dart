part of 'app_router.dart';

/// Auth routing policy (maps auth status to allowed routes + default redirect).
final class _AuthRoutingPolicy {
  /// Creates an auth routing policy definition.
  const _AuthRoutingPolicy({
    /// Route name to redirect to when the current route is not allowed.
    required this.redirectRouteName,

    /// Allowed route names for the current auth status.
    required this.allowedRouteNames,
  });

  /// Default route to redirect to if the current route is not allowed.
  final String redirectRouteName;

  /// Set of route names allowed for this auth status.
  final Set<String> allowedRouteNames;
}

/// Auth routing policies keyed by authentication status.
final Map<bool, _AuthRoutingPolicy> _authRoutingPolicies =
    <bool, _AuthRoutingPolicy>{
      // Policy for unauthenticated users.
      false: _AuthRoutingPolicy(
        redirectRouteName: SignInRoute.routeName,
        allowedRouteNames: <String>{
          SignInRoute.routeName,
          VerifySignInRoute.routeName,
          SignUpRoute.routeName,
          VerifySignUpRoute.routeName,
        },
      ),
      // Policy for authenticated users.
      true: _AuthRoutingPolicy(
        redirectRouteName: FeedRoute.routeName,
        allowedRouteNames: <String>{
          FeedRoute.routeName,
          CommunityRoute.routeName,
          CreateRoute.routeName,
          SendRoute.routeName,
          NotificationsRoute.routeName,
          MemeDetailsRoute.routeName,
          CurrentUserDetailsRoute.routeName,
          UserDetailsRoute.routeName,
          FriendshipsRoute.routeName,
          SettingsRoute.routeName,
          LanguageModeRoute.routeName,
          ChangeEmailRoute.routeName,
          ChangePasswordRoute.routeName,
          DeleteAccountRoute.routeName,
        },
      ),
    };

/// Central redirect logic.
///
/// Why we keep this in a dedicated file:
/// - redirects often become complex (extras/path params validation)
/// - keeping it separate keeps `app_router.dart` readable
///
/// Redirect policy (deterministic order):
/// 0. If on "/" (root) → route based on auth state
/// 1. Validate route state (missing required extras/params) → safe route
/// 2. If route not allowed for current auth state → redirect to default route
/// 3. Otherwise → allow navigation (return null)
String? _redirect(BuildContext context, GoRouterState state, Ref ref) {
  // Read auth state synchronously for deterministic redirects.
  final AsyncValue<AuthStateEntity> authState = ref.read(authStateProvider);

  // If auth state is still loading, allow navigation.
  if (!authState.hasValue) {
    return null;
  }

  final bool isAuthenticated = authState.value!.isAuthenticated;

  final String location = state.uri.toString();
  final String path = state.uri.path;

  // Root path ("/") is a pure routing decision point.
  // It never renders - always redirects based on auth state.
  if (path == '/') {
    final String target = authState.value!.isAuthenticated
        ? state.namedLocation(FeedRoute.routeName)
        : state.namedLocation(SignInRoute.routeName);

    return target == location ? null : target;
  }

  final String? routeName = state.topRoute?.name;
  if (routeName == null) {
    return null;
  }

  // Apply auth routing policy.
  final _AuthRoutingPolicy policy = _authRoutingPolicies[isAuthenticated]!;

  // If we have a route name and it's allowed by the policy, allow navigation.
  if (policy.allowedRouteNames.contains(routeName)) {
    return null; // allow
  }

  // If the route name is unknown or not allowed, redirect to the policy's default.
  final String target = state.namedLocation(policy.redirectRouteName);

  // Prevent redirect loop: if target equals current URI, don't redirect.
  return target == location ? null : target;
}
