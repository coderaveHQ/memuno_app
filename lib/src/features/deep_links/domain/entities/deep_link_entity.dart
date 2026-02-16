import 'package:memuno_app/src/features/deep_links/domain/entities/deep_link_destination.dart';

/// Immutable deep-link resolution result.
///
/// This entity is produced by the domain usecase and consumed by the
/// presentation layer for navigation.
final class DeepLinkEntity {
  /// Creates a deep-link resolution snapshot.
  const DeepLinkEntity({
    /// Original URI received from the operating system or app payload.
    required this.originalUri,

    /// Normalized app path extracted from [originalUri].
    required this.normalizedPath,

    /// Destination resolved from [normalizedPath].
    required this.destination,
  });

  /// Original URI received from the operating system or app payload.
  final Uri originalUri;

  /// Normalized app path extracted from [originalUri].
  final String normalizedPath;

  /// Destination resolved from [normalizedPath].
  final DeepLinkDestination destination;

  /// Whether this deep link targets the auth callback route.
  bool get isAuthCallback => destination == DeepLinkDestination.authCallback;
}
