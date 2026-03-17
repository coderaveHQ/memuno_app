import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/navigation/presentation/pages/main_shell_page.dart';
import 'package:memuno_app/src/app/router/extras_codec.dart';
import 'package:memuno_app/src/app/router/route_utils.dart';
import 'package:memuno_app/src/core/error/error_page.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_router_refresh_provider.dart';
import 'package:memuno_app/src/features/auth/application/providers/auth_state_provider.dart';
import 'package:memuno_app/src/features/auth/domain/entities/auth_state_entity.dart';
import 'package:memuno_app/src/features/auth/presentation/pages/auth_callback_page.dart';
import 'package:memuno_app/src/features/auth/presentation/pages/change_email_page.dart';
import 'package:memuno_app/src/features/auth/presentation/pages/change_password_page.dart';
import 'package:memuno_app/src/features/auth/presentation/pages/delete_account_page.dart';
import 'package:memuno_app/src/features/auth/presentation/pages/sign_in_page.dart';
import 'package:memuno_app/src/features/auth/presentation/pages/sign_up_page.dart';
import 'package:memuno_app/src/features/auth/presentation/pages/verify_sign_in_page.dart';
import 'package:memuno_app/src/features/auth/presentation/pages/verify_sign_up_page.dart';
import 'package:memuno_app/src/features/create_meme/presentation/pages/meme_editor_page.dart';
import 'package:memuno_app/src/features/create_meme/presentation/pages/send_meme_page.dart';
import 'package:memuno_app/src/features/feed/presentation/pages/feed_page.dart';
import 'package:memuno_app/src/features/friendships/presentation/pages/friendships_page.dart';
import 'package:memuno_app/src/features/group_details/presentation/pages/group_details_info_page.dart';
import 'package:memuno_app/src/features/group_details/presentation/pages/group_details_page.dart';
import 'package:memuno_app/src/features/groups/presentation/pages/group_create_members_sheet_page.dart';
import 'package:memuno_app/src/features/groups/presentation/pages/group_create_name_sheet_page.dart';
import 'package:memuno_app/src/features/groups/presentation/pages/group_create_sheet_shell.dart';
import 'package:memuno_app/src/features/groups/presentation/pages/groups_page.dart';
import 'package:memuno_app/src/features/meme_details/presentation/pages/meme_details_page.dart';
import 'package:memuno_app/src/features/notifications/presentation/pages/notifications_page.dart';
import 'package:memuno_app/src/features/settings/presentation/pages/language_mode_page.dart';
import 'package:memuno_app/src/features/settings/presentation/pages/settings_page.dart';
import 'package:memuno_app/src/features/user_details/presentation/pages/user_details_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

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
  // Get the refresh listenable (notifies on auth state changes).
  final ChangeNotifier refreshListenable = ref.watch(authRouterRefreshProvider);

  // Build the router configuration.
  final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: $appRoutes,
    extraCodec: const AppExtraCodec(),
    refreshListenable: refreshListenable,
    errorBuilder: (BuildContext context, GoRouterState state) {
      final Exception error = (state.error is Exception)
          ? state.error! as Exception
          : Exception(state.error?.toString() ?? 'Unknown routing error');

      return ErrorRoute(error: error).build(context, state);
    },
    redirect: (BuildContext context, GoRouterState state) {
      // Use real redirect logic
      return _redirect(context, state, ref);
    },
  );

  // Dispose router when provider is disposed.
  ref.onDispose(() {
    router.dispose();
  });

  return router;
}
