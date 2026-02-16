import 'dart:convert';

/// Central GoRouter `extra` codec.
///
/// We keep this file even if it's "empty" today because:
/// - our app will later pass typed extras between routes
/// - GoRouter can persist extras across state restoration when a codec exists
///
/// For now, we only support `null`.
/// Codec used by GoRouter for serializing `extra` values.
final class AppExtraCodec extends Codec<Object?, Object?> {
  /// Creates the app extra codec.
  const AppExtraCodec();

  /// Decoder used when restoring extras.
  @override
  Converter<Object?, Object?> get decoder => const _AppExtraDecoder();

  /// Encoder used when persisting extras.
  @override
  Converter<Object?, Object?> get encoder => const _AppExtraEncoder();
}

/// Decoder for route extras.
final class _AppExtraDecoder extends Converter<Object?, Object?> {
  /// Creates the decoder.
  const _AppExtraDecoder();

  /// Converts a raw serialized value into a runtime extra.
  @override
  Object? convert(Object? input) {
    if (input == null) {
      return null;
    }

    final Object? data = input is String ? _tryJsonDecode(input) : input;

    if (_isJsonSafe(data)) {
      return data;
    }

    // Future: decode known types.
    throw FormatException('Unable to decode extra: $input');
  }

  /// Attempts to JSON-decode a serialized route extra value.
  Object? _tryJsonDecode(String input) {
    try {
      return jsonDecode(input);
    } catch (_) {
      return input;
    }
  }

  /// Returns whether the value can be safely encoded as JSON.
  bool _isJsonSafe(Object? value) {
    return value == null ||
        value is String ||
        value is num ||
        value is bool ||
        value is List ||
        value is Map;
  }
}

/// Encoder for route extras.
final class _AppExtraEncoder extends Converter<Object?, Object?> {
  /// Creates the encoder.
  const _AppExtraEncoder();

  /// Converts a runtime extra into a serialized value.
  @override
  Object? convert(Object? input) {
    if (input == null) {
      return null;
    }

    if (_isJsonSafe(input)) {
      return input;
    }

    // Future: encode known types.
    throw FormatException('Cannot encode type ${input.runtimeType}');
  }

  /// Returns whether the value can be safely encoded as JSON.
  bool _isJsonSafe(Object? value) {
    return value == null ||
        value is String ||
        value is num ||
        value is bool ||
        value is List ||
        value is Map;
  }
}
