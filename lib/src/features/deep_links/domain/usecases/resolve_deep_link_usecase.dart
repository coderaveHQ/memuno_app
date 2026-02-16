import 'package:memuno_app/src/features/deep_links/domain/entities/deep_link_destination.dart';
import 'package:memuno_app/src/features/deep_links/domain/entities/deep_link_entity.dart';

/// Usecase that resolves an external URI into an in-app destination.
///
/// The resolver normalizes custom-scheme links, App/Universal links, and
/// relative paths into a canonical app path before matching a destination.
final class ResolveDeepLinkUsecase {
  /// Creates the deep-link resolver.
  const ResolveDeepLinkUsecase({
    /// Supported custom URL schemes across all app flavors.
    required Set<String> supportedCustomSchemes,
  }) : _supportedCustomSchemes = supportedCustomSchemes;

  /// Supported custom URL schemes across all app flavors.
  final Set<String> _supportedCustomSchemes;

  /// Path-to-destination mapping for all routable app deep links.
  static const Map<String, DeepLinkDestination> _destinationByPath =
      <String, DeepLinkDestination>{
        '/': DeepLinkDestination.root,
        '/auth/callback': DeepLinkDestination.authCallback,
      };

  /// Resolves [uri] into an app destination.
  ///
  /// Returns `null` when the URI cannot be mapped to any supported route.
  DeepLinkEntity? call(Uri uri) {
    final String? extractedPath = _extractPath(uri);
    if (extractedPath == null) {
      return null;
    }

    final String normalizedPath = _normalizePath(extractedPath);
    final DeepLinkDestination? destination = _destinationByPath[normalizedPath];
    if (destination == null) {
      return null;
    }

    return DeepLinkEntity(
      originalUri: uri,
      normalizedPath: normalizedPath,
      destination: destination,
    );
  }

  /// Extracts the raw in-app path from [uri].
  String? _extractPath(Uri uri) {
    if (_supportedCustomSchemes.contains(uri.scheme)) {
      return _buildPathFromCustomScheme(uri);
    }

    if (uri.scheme.isEmpty || uri.scheme == 'http' || uri.scheme == 'https') {
      final String? fragmentPath = _extractPathFromFragment(uri.fragment);
      if (fragmentPath != null) {
        return fragmentPath;
      }

      if (uri.path.isNotEmpty) {
        return uri.path;
      }

      return '/';
    }

    return null;
  }

  /// Builds a path from a custom-scheme URI.
  ///
  /// Example:
  /// - `my.app://auth/callback` -> `/auth/callback`
  String _buildPathFromCustomScheme(Uri uri) {
    final List<String> segments = <String>[
      if (uri.host.isNotEmpty) uri.host,
      ...uri.pathSegments.where((String segment) => segment.isNotEmpty),
    ];

    if (segments.isEmpty) {
      return '/';
    }

    return '/${segments.join('/')}';
  }

  /// Attempts to read a path from [fragment] when it contains route-style data.
  String? _extractPathFromFragment(String fragment) {
    if (!fragment.startsWith('/')) {
      return null;
    }

    try {
      final Uri fragmentUri = Uri.parse(fragment);
      if (fragmentUri.path.isEmpty) {
        return '/';
      }
      return fragmentUri.path;
    } on FormatException {
      return null;
    }
  }

  /// Normalizes [path] into a canonical app route path.
  String _normalizePath(String path) {
    final String withLeadingSlash = path.startsWith('/') ? path : '/$path';
    final String collapsedSlashes = withLeadingSlash.replaceAll(
      RegExp(r'/+'),
      '/',
    );

    if (collapsedSlashes.length > 1 && collapsedSlashes.endsWith('/')) {
      return collapsedSlashes.substring(0, collapsedSlashes.length - 1);
    }

    return collapsedSlashes;
  }
}
