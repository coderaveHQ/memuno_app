import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'external_url_launcher.g.dart';

/// App-layer wrapper for launching external URLs.
final class ExternalUrlLauncher {
  /// Creates a URL launcher wrapper.
  const ExternalUrlLauncher();

  /// Opens [uri] using an external application when available.
  Future<bool> open(Uri uri) {
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Dependency-injected access to [ExternalUrlLauncher].
@riverpod
ExternalUrlLauncher externalUrlLauncher(Ref ref) {
  return const ExternalUrlLauncher();
}
