import 'package:app_links/app_links.dart';
import 'package:memuno_app/src/infrastructure/deep_links/app_links_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'incoming_deep_link_provider.g.dart';

/// Provides external deep links emitted by the operating system.
///
/// This stream merges the initial link and subsequent link events, while
/// suppressing exact duplicates.
@Riverpod(keepAlive: true)
Stream<Uri> incomingDeepLink(Ref ref) async* {
  /// AppLinks plugin entrypoint.
  final AppLinks appLinks = ref.watch(appLinksProvider);

  /// Tracks emitted URIs so subscribers do not process duplicates.
  final Set<String> emittedLinks = <String>{};

  // Read the launch-time deep link.
  final Uri? initialLink = await appLinks.getInitialLink();
  if (initialLink != null && emittedLinks.add(initialLink.toString())) {
    yield initialLink;
  }

  // Forward links received while the app is running.
  await for (final Uri uri in appLinks.uriLinkStream) {
    if (emittedLinks.add(uri.toString())) {
      yield uri;
    }
  }
}
