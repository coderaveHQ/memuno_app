part of 'app_router.dart';

/// Central redirect logic.
///
/// Why we keep this in a dedicated file:
/// - redirects often become complex (extras/path params validation)
/// - keeping it separate keeps `app_router.dart` readable
