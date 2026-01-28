import 'dart:convert';

/// Central GoRouter `extra` codec.
///
/// We keep this file even if it's "empty" today because:
/// - our app will later pass typed extras between routes
/// - GoRouter can persist extras across state restoration when a codec exists
///
/// For now, we only support `null`.
final class AppExtraCodec extends Codec<Object?, Object?> {
  const AppExtraCodec();

  @override
  Converter<Object?, Object?> get decoder => const _AppExtraDecoder();

  @override
  Converter<Object?, Object?> get encoder => const _AppExtraEncoder();
}

final class _AppExtraDecoder extends Converter<Object?, Object?> {
  const _AppExtraDecoder();

  @override
  Object? convert(Object? input) {
    if (input == null) {
      return null;
    }

    // Future: decode known types.
    throw FormatException('Unable to decode extra: $input');
  }
}

final class _AppExtraEncoder extends Converter<Object?, Object?> {
  const _AppExtraEncoder();

  @override
  Object? convert(Object? input) {
    if (input == null) {
      return null;
    }

    // Future: encode known types.
    throw FormatException('Cannot encode type ${input.runtimeType}');
  }
}
