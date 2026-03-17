part of 'app_router.dart';

/// Root navigator key used for typed routes.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> groupCreateSheetNavigatorKey =
    GlobalKey<NavigatorState>();

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
    TypedGoRoute<FriendshipsRoute>(
      path: '/friendships',
      name: FriendshipsRoute.routeName,
    ),
    TypedGoRoute<GroupsRoute>(
      path: '/groups',
      name: GroupsRoute.routeName,
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<GroupDetailsRoute>(
          path: ':groupId',
          name: GroupDetailsRoute.routeName,
          routes: <TypedRoute<RouteData>>[
            TypedGoRoute<GroupDetailsInfoRoute>(
              path: 'info',
              name: GroupDetailsInfoRoute.routeName,
            ),
          ],
        ),
      ],
    ),
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

@TypedShellRoute<GroupCreateSheetRoute>(
  routes: <TypedRoute<RouteData>>[
    TypedGoRoute<GroupCreateNameSheetRoute>(
      path: '/groups/create/name',
      name: GroupCreateNameSheetRoute.routeName,
      routes: <TypedRoute<RouteData>>[
        TypedGoRoute<GroupCreateMembersSheetRoute>(
          path: 'members',
          name: GroupCreateMembersSheetRoute.routeName,
        ),
      ],
    ),
  ],
)
class GroupCreateSheetRoute extends ShellRouteData {
  const GroupCreateSheetRoute();

  static final GlobalKey<NavigatorState> $navigatorKey =
      groupCreateSheetNavigatorKey;

  @override
  Page<void> pageBuilder(
    BuildContext context,
    GoRouterState state,
    Widget navigator,
  ) {
    return ModalSheetPage<void>(
      key: state.pageKey,
      swipeDismissible: true,
      viewportBuilder: (BuildContext context, Widget child) {
        return SheetViewport(
          padding: EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
          child: child,
        );
      },
      child: GroupCreateSheetShell(navigator: navigator),
    );
  }
}

class GroupCreateNameSheetRoute extends GoRouteData
    with $GroupCreateNameSheetRoute {
  const GroupCreateNameSheetRoute();

  static const String routeName = 'groupCreateNameSheet';

  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      groupCreateSheetNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return PagedSheetPage<void>(
      key: state.pageKey,
      initialOffset: const SheetOffset(0.6),
      snapGrid: const SheetSnapGrid(
        snaps: <SheetOffset>[SheetOffset(0.6), SheetOffset(1)],
      ),
      child: const GroupCreateNameSheetPage(),
    );
  }
}

class GroupCreateMembersSheetRoute extends GoRouteData
    with $GroupCreateMembersSheetRoute {
  const GroupCreateMembersSheetRoute();

  static const String routeName = 'groupCreateMembersSheet';

  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      groupCreateSheetNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return PagedSheetPage<void>(
      key: state.pageKey,
      child: const GroupCreateMembersSheetPage(),
    );
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
  static final GlobalKey<NavigatorState> $parentNavigatorKey =
      shellNavigatorKey;

  @override
  /// Builds the page for this route.
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage<void>(
      child: FriendshipsPage(
        initialTab: FriendshipsPageTab.fromRouteValue(tab),
      ),
    );
  }
}

class GroupsRoute extends GoRouteData with $GroupsRoute {
  /// Creates the groups route.
  const GroupsRoute({this.tab});

  /// Optional initial tab query value (`groups` or `invitations`).
  final String? tab;

  /// Route name used in navigation.
  static const String routeName = 'groups';

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
    return NoTransitionPage<void>(
      child: GroupsPage(initialTab: GroupsPageTab.fromRouteValue(tab)),
    );
  }
}

class GroupDetailsRoute extends GoRouteData with $GroupDetailsRoute {
  /// Creates the group details route.
  const GroupDetailsRoute({required this.groupId});

  /// Group id path parameter.
  final String groupId;

  /// Route name used in navigation.
  static const String routeName = 'groupDetails';

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
    return GroupDetailsPage(groupId: groupId);
  }
}

class GroupDetailsInfoRoute extends GoRouteData with $GroupDetailsInfoRoute {
  /// Creates the group details info route.
  const GroupDetailsInfoRoute({required this.groupId});

  /// Group id path parameter.
  final String groupId;

  /// Route name used in navigation.
  static const String routeName = 'groupDetailsInfo';

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
    return GroupDetailsInfoPage(groupId: groupId);
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

@TypedGoRoute<CurrentUserDetailsRoute>(
  path: '/profile',
  name: CurrentUserDetailsRoute.routeName,
)
class CurrentUserDetailsRoute extends GoRouteData
    with $CurrentUserDetailsRoute {
  /// Creates the current-user details route.
  const CurrentUserDetailsRoute();

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
    final ProviderContainer container = ProviderScope.containerOf(
      context,
      listen: false,
    );
    final AsyncValue<AuthStateEntity> authState = container.read(
      authStateProvider,
    );
    final String? userId = authState.asData?.value.user?.id;

    if (userId == null) {
      throw StateError('Expected authenticated user id for /profile route.');
    }

    return UserDetailsPage(userId: userId);
  }
}

@TypedGoRoute<UserDetailsRoute>(
  path: '/users/:userId',
  name: UserDetailsRoute.routeName,
)
class UserDetailsRoute extends GoRouteData with $UserDetailsRoute {
  /// Creates the user-details route.
  const UserDetailsRoute({required this.userId});

  /// User id path parameter.
  final String userId;

  /// Route name used in navigation.
  static const String routeName = 'userDetails';

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
    return UserDetailsPage(userId: userId);
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
