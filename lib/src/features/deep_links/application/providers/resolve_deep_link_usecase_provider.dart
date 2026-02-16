import 'package:memuno_app/src/core/config/app_env.dart';
import 'package:memuno_app/src/features/deep_links/domain/usecases/resolve_deep_link_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'resolve_deep_link_usecase_provider.g.dart';

/// Provides the deep-link resolver usecase.
@Riverpod(keepAlive: true)
ResolveDeepLinkUsecase resolveDeepLinkUsecase(Ref ref) {
  // Accept all flavor schemes so links remain valid across development,
  // staging, and production app builds.
  return ResolveDeepLinkUsecase(
    supportedCustomSchemes: AppEnv.supportedDeepLinkSchemes,
  );
}
