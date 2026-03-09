part of 'app_router.dart';

/// Root navigator key used for typed routes.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

/// Route shown when GoRouter catches an error.
class ErrorRoute extends GoRouteData {
  /// Creates the error route with the captured [error].
  const ErrorRoute({required this.error});

  /// Error thrown by the router or page builder.
  final Exception error;

  @override
  /// Builds the error route widget.
  Widget build(BuildContext context, GoRouterState state) {
    return ErrorPage(error: error);
  }
}

@TypedGoRoute<AuthCallbackRoute>(
  path: '/auth/callback',
  name: AuthCallbackRoute.routeName,
)
class AuthCallbackRoute extends GoRouteData with $AuthCallbackRoute {
  /// Creates the auth callback route.
  const AuthCallbackRoute();

  /// Route name used in navigation.
  static const String routeName = 'authCallback';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return const NoTransitionPage<void>(child: AuthCallbackPage());
  }
}

@TypedGoRoute<SignInRoute>(
  path: '/sign-in',
  name: SignInRoute.routeName,
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<VerifySignInRoute>(
      path: 'verify',
      name: VerifySignInRoute.routeName,
    ),
  ],
)
class SignInRoute extends GoRouteData with $SignInRoute {
  /// Creates the sign-in route.
  const SignInRoute();

  /// Route name used in navigation.
  static const String routeName = 'signIn';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage<void>(child: const SignInPage());
  }
}

class VerifySignInRoute extends GoRouteData with $VerifySignInRoute {
  final String $extra;

  /// Creates a VerifySignInRoute instance.
  const VerifySignInRoute(this.$extra);

  static const String routeName = 'verifySignIn';

  /// Returns whether leaf.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns whether in stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, GoRouterState state) {
    return VerifySignInPage(email: $extra);
  }
}

@TypedGoRoute<SignUpRoute>(
  path: '/sign-up',
  name: SignUpRoute.routeName,
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<VerifySignUpRoute>(
      path: 'verify',
      name: VerifySignUpRoute.routeName,
    ),
  ],
)
class SignUpRoute extends GoRouteData with $SignUpRoute {
  /// Creates the sign-up route.
  const SignUpRoute();

  /// Route name used in navigation.
  static const String routeName = 'signUp';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return const SignUpPage();
  }
}

class VerifySignUpRoute extends GoRouteData with $VerifySignUpRoute {
  final String $extra;

  /// Creates a VerifySignUpRoute instance.
  const VerifySignUpRoute(this.$extra);

  static const String routeName = 'verifySignUp';

  /// Returns whether leaf.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns whether in stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context, GoRouterState state) {
    return VerifySignUpPage(email: $extra);
  }
}

@TypedShellRoute<MainRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<FeedRoute>(path: '/feed', name: FeedRoute.routeName),
    TypedGoRoute<CommunityRoute>(path: '/m', name: CommunityRoute.routeName),
  ],
)
class MainRoute extends ShellRouteData {
  const MainRoute();

  static final GlobalKey<NavigatorState> $navigatorKey = shellNavigatorKey;

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    return NoTransitionPage(child: MainShellPage(navigator: navigator));
  }
}

class FeedRoute extends GoRouteData with $FeedRoute {
  /// Creates the feed route.
  const FeedRoute();

  /// Route name used in navigation.
  static const String routeName = 'feed';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      shellNavigatorKey;

  @override
  /// Builds the page for this route.
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage<void>(child: const FeedPage());
  }
}

class CommunityRoute extends GoRouteData with $CommunityRoute {
  /// Creates the community route.
  const CommunityRoute();

  /// Route name used in navigation.
  static const String routeName = 'm';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      shellNavigatorKey;

  @override
  /// Builds the page for this route.
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage<void>(child: const CommunityPage());
  }
}

@TypedGoRoute<CreateRoute>(
  path: '/create',
  name: CreateRoute.routeName,
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<SendRoute>(path: 'send', name: SendRoute.routeName),
  ],
)
class CreateRoute extends GoRouteData with $CreateRoute {
  /// Creates the create route.
  const CreateRoute();

  /// Route name used in navigation.
  static const String routeName = 'create';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return const MemeEditorPage();
  }
}

class SendRoute extends GoRouteData with $SendRoute {
  /// Finalized meme bytes forwarded to send flow.
  final List<int> $extra;

  /// Creates the send route.
  const SendRoute(this.$extra);

  /// Route name used in navigation.
  static const String routeName = 'send';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return SendMemePage(memeBytes: $extra);
  }
}

@TypedGoRoute<NotificationsRoute>(
  path: '/notifications',
  name: NotificationsRoute.routeName,
)
class NotificationsRoute extends GoRouteData with $NotificationsRoute {
  /// Creates the notifications route.
  const NotificationsRoute();

  /// Route name used in navigation.
  static const String routeName = 'notifications';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return const NotificationsPage();
  }
}

@TypedGoRoute<MemeDetailsRoute>(
  path: '/memes/:memeId',
  name: MemeDetailsRoute.routeName,
)
class MemeDetailsRoute extends GoRouteData with $MemeDetailsRoute {
  /// Creates the meme details route.
  const MemeDetailsRoute({required this.memeId});

  /// Meme id path parameter.
  final String memeId;

  /// Route name used in navigation.
  static const String routeName = 'memeDetails';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return MemeDetailsPage(memeId: memeId);
  }
}

@TypedGoRoute<ProfileRoute>(path: '/profile', name: ProfileRoute.routeName)
class ProfileRoute extends GoRouteData with $ProfileRoute {
  /// Creates the profile route.
  const ProfileRoute();

  /// Route name used in navigation.
  static const String routeName = 'profile';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return const ProfilePage();
  }
}

@TypedGoRoute<FriendshipsRoute>(
  path: '/friendships',
  name: FriendshipsRoute.routeName,
)
class FriendshipsRoute extends GoRouteData with $FriendshipsRoute {
  /// Creates the friendships route.
  const FriendshipsRoute({this.tab});

  /// Optional initial tab query value (`friendships` or `requests`).
  final String? tab;

  /// Route name used in navigation.
  static const String routeName = 'friendships';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return FriendshipsPage(initialTab: FriendshipsPageTab.fromRouteValue(tab));
  }
}

@TypedGoRoute<SettingsRoute>(
  path: '/settings',
  name: SettingsRoute.routeName,
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<LanguageModeRoute>(
      path: 'language-mode',
      name: LanguageModeRoute.routeName,
    ),
    TypedGoRoute<ChangeEmailRoute>(
      path: 'change-email',
      name: ChangeEmailRoute.routeName,
    ),
    TypedGoRoute<ChangePasswordRoute>(
      path: 'change-password',
      name: ChangePasswordRoute.routeName,
    ),
    TypedGoRoute<DeleteAccountRoute>(
      path: 'delete-account',
      name: DeleteAccountRoute.routeName,
    ),
  ],
)
class SettingsRoute extends GoRouteData with $SettingsRoute {
  /// Creates the settings route.
  const SettingsRoute();

  /// Route name used in navigation.
  static const String routeName = 'settings';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsPage();
  }
}

class LanguageModeRoute extends GoRouteData with $LanguageModeRoute {
  /// Creates the settings language mode route.
  const LanguageModeRoute();

  /// Route name used in navigation.
  static const String routeName = 'languageMode';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return const LanguageModePage();
  }
}

class ChangeEmailRoute extends GoRouteData with $ChangeEmailRoute {
  /// Creates the settings change email route.
  const ChangeEmailRoute();

  /// Route name used in navigation.
  static const String routeName = 'changeEmail';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return const ChangeEmailPage();
  }
}

class ChangePasswordRoute extends GoRouteData with $ChangePasswordRoute {
  /// Creates the settings change password route.
  const ChangePasswordRoute();

  /// Route name used in navigation.
  static const String routeName = 'changePassword';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return const ChangePasswordPage();
  }
}

class DeleteAccountRoute extends GoRouteData with $DeleteAccountRoute {
  /// Creates the settings delete account route.
  const DeleteAccountRoute();

  /// Route name used in navigation.
  static const String routeName = 'deleteAccount';

  /// Returns true if this route is the top-most leaf in the stack.
  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  /// Returns true if this route exists anywhere in the stack.
  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  /// Parent navigator used by this route.
  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  /// Builds the page for this route.
  Widget build(BuildContext context, GoRouterState state) {
    return const DeleteAccountPage();
  }
}
