import 'package:go_router/go_router.dart';
import 'package:memuno_app/src/app/router/app_router.dart';
import 'package:memuno_app/src/core/providers/logger_provider.dart';
import 'package:memuno_app/src/core/utils/logger.dart';
import 'package:memuno_app/src/features/deep_links/application/providers/resolve_deep_link_usecase_provider.dart';
import 'package:memuno_app/src/features/deep_links/domain/entities/deep_link_destination.dart';
import 'package:memuno_app/src/features/deep_links/domain/entities/deep_link_entity.dart';
import 'package:memuno_app/src/features/deep_links/domain/usecases/resolve_deep_link_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'deep_link_navigation_handler_provider.g.dart';

/// Function signature for handling a single incoming deep link.
typedef DeepLinkNavigationHandler = void Function(Uri uri);

/// Provides a navigation handler for external deep links.
///
/// This handler can be reused by App Links and future push-notification
/// payload handling to keep routing behavior consistent.
@Riverpod(keepAlive: true)
DeepLinkNavigationHandler deepLinkNavigationHandler(Ref ref) {
  /// Usecase that resolves incoming URIs into app destinations.
  final ResolveDeepLinkUsecase resolveDeepLinkUsecase = ref.watch(
    resolveDeepLinkUsecaseProvider,
  );

  /// Logger used for deep-link diagnostics.
  final Logger logger = ref.watch(loggerProvider);

  return (Uri uri) {
    final DeepLinkEntity? deepLink = resolveDeepLinkUsecase(uri);
    if (deepLink == null) {
      logger.info(message: 'Ignoring unsupported deep link: $uri');
      return;
    }

    final String targetLocation = _locationForDestination(deepLink.destination);

    final GoRouter router = ref.read(appRouterProvider);
    final Uri currentUri = router.routeInformationProvider.value.uri;
    final Uri targetUri = Uri.parse(targetLocation);

    if (currentUri.path == targetUri.path &&
        currentUri.query == targetUri.query) {
      logger.info(
        message: 'Deep link already on target route: $targetLocation',
      );
      return;
    }

    logger.info(
      message: 'Navigating via deep link to $targetLocation (from $uri)',
    );
    router.go(targetLocation);
  };
}

/// Maps a [destination] to its canonical GoRouter location.
String _locationForDestination(DeepLinkDestination destination) {
  return switch (destination) {
    DeepLinkDestination.root => '/',
    DeepLinkDestination.authCallback => const AuthCallbackRoute().location,
  };
}
