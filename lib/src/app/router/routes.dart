part of 'app_router.dart';

/// Root navigator key used for typed routes.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Route shown when GoRouter catches an error.
class ErrorRoute extends GoRouteData {
  const ErrorRoute({required this.error});
  final Exception error;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return ErrorPage(error: error);
  }
}

@TypedGoRoute<SignInRoute>(path: '/sign-in', name: SignInRoute.routeName)
class SignInRoute extends GoRouteData with $SignInRoute {
  const SignInRoute();

  static const String routeName = 'signIn';

  static bool isLeaf(BuildContext context) =>
      RouteUtils.isLeaf(context, routeName);

  static bool isInStack(BuildContext context) =>
      RouteUtils.isInStack(context, routeName);

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Page<void> buildPage(BuildContext context, GoRouterState state) {
    return NoTransitionPage<void>(child: const SignInPage());
  }
}
