import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// GoRouter-related navigation helpers.
///
/// Why this exists:
/// - GoRouter gives us multiple ways to access the "current route":
///   - `GoRouterState.of(context).name` (fast, but can be null in some cases)
///   - `GoRouter.of(context).routerDelegate.currentConfiguration` (always available,
///     but requires parsing the route match tree)
/// - In redirects / UI logic we often need:
///   - "What is the current leaf route name?"
///   - "Am I currently on route X?"
///   - "Is route X somewhere in the current navigation stack?"
///
/// Important note:
/// - We use route *names* (TypedGoRoute names) rather than paths because:
///   - names are stable even if paths change
///   - names make redirect policies easier to express and audit
final class RouteUtils {
  /// Private constructor to prevent instantiation.
  ///
  /// This class is a pure static utility.
  const RouteUtils._();

  /// Returns the *leaf* (deepest active) route name for the current navigation state.
  ///
  /// What "leaf" means:
  /// - If the route tree is nested, the leaf is the last matched route in the stack.
  ///   Example: `/sign-in/verify` -> leaf is `verifySignIn` (the nested route)
  ///
  /// Implementation detail:
  /// 1) First try `GoRouterState.of(context).name` (fast path).
  /// 2) If that is null, inspect the current match list and extract the leaf route.
  static String? leafRouteName(BuildContext context) {
    // Fast path: if the state already has a name, prefer it.
    final String? name = GoRouterState.of(context).name;
    if (name != null) return name;

    // Fallback: inspect the current match configuration from the router.
    final RouteMatchList config = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration;

    // If there are no matches, there is no active route.
    if (config.matches.isEmpty) return null;

    // The last match in the list represents the deepest active branch.
    final RouteMatchBase last = config.matches.last;

    // Extract the leaf route name from the RouteBase tree.
    return _extractLeafNameFromRouteBase(last.route);
  }

  /// Returns true if the current leaf route name equals [routeName].
  ///
  /// This is useful for UI that should only be active on a specific screen,
  /// e.g. showing a FAB only on the Feed page.
  static bool isLeaf(BuildContext context, String routeName) {
    final String? leaf = leafRouteName(context);
    return leaf != null && leaf == routeName;
  }

  /// Returns true if a route with name [routeName] appears anywhere
  /// in the current route match stack (including parents).
  ///
  /// Example:
  /// - If the current route is `/settings/change-email`,
  ///   then `isInStack(context, SettingsRoute.routeName)` should be true.
  ///
  /// Why not only use `GoRouterState.of(context).name`?
  /// - That only tells us the leaf name, not whether a parent is present.
  static bool isInStack(BuildContext context, String routeName) {
    // Quick check: if the leaf name equals routeName, we're obviously in stack.
    final String? direct = GoRouterState.of(context).name;
    if (direct == routeName) return true;

    // Otherwise scan the full match list and search within each match tree.
    final RouteMatchList config = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration;

    for (final RouteMatchBase match in config.matches) {
      if (_routeTreeContainsName(match.route, routeName)) {
        return true;
      }
    }

    return false;
  }

  /// Returns true if [base] (or any nested child) contains a GoRoute
  /// with name [routeName].
  ///
  /// This is a depth-first traversal of the route tree.
  static bool _routeTreeContainsName(RouteBase base, String routeName) {
    // Only GoRoute has a `name`. ShellRoute/StatefulShellRoute do not.
    if (base is GoRoute && base.name == routeName) return true;

    // Traverse children recursively.
    final List<RouteBase> children = base.routes;
    for (final RouteBase child in children) {
      if (_routeTreeContainsName(child, routeName)) return true;
    }

    return false;
  }

  /// Extracts the leaf route name from a [RouteBase] tree.
  ///
  /// Notes:
  /// - If [base] is a GoRoute, its name is returned.
  /// - If [base] is not a GoRoute (e.g. ShellRoute), we walk down its children
  ///   and keep picking the last child as the "deepest" leaf.
  /// - If there are no children, null is returned.
  static String? _extractLeafNameFromRouteBase(RouteBase base) {
    if (base is GoRoute) return base.name;

    final List<RouteBase> children = base.routes;
    if (children.isEmpty) return null;

    return _extractLeafNameFromRouteBase(children.last);
  }
}
