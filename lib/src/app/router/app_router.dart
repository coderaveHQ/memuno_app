import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:memuno_app/src/app/router/extras_codec.dart';
import 'package:memuno_app/src/app/router/route_utils.dart';
import 'package:memuno_app/src/core/error/error_page.dart';
import 'package:memuno_app/src/features/auth/presentation/pages/sign_in_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';
part 'redirects.dart';
part 'routes.dart';

/// Provides the app router.
///
/// We keep routing state in one place:
/// - typed routes live in `routes.dart`
/// - redirect logic lives in `redirects.dart`
/// - global navigator key is also in `routes.dart`
@riverpod
GoRouter appRouter(Ref ref) {
  final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: $appRoutes,
    extraCodec: const AppExtraCodec(),
    errorBuilder: (BuildContext context, GoRouterState state) {
      final Exception error = (state.error is Exception)
          ? state.error! as Exception
          : Exception(state.error?.toString() ?? 'Unknown routing error');

      return ErrorRoute(error: error).build(context, state);
    },
    redirect: (BuildContext context, GoRouterState state) {
      return '/sign-in';
    },
  );

  // Dispose router when provider is disposed.
  ref.onDispose(() {
    router.dispose();
  });

  return router;
}
