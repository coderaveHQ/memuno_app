import 'package:app_links/app_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_links_provider.g.dart';

/// Riverpod provider for [AppLinks].
@Riverpod(keepAlive: true)
AppLinks appLinks(Ref ref) {
  // Create a new AppLinks instance for deep link handling.
  return AppLinks();
}
