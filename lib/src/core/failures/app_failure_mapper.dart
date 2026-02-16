import 'dart:io';

import 'package:memuno_app/src/core/failures/failure.dart';
import 'package:memuno_app/src/core/failures/failure_mapper.dart';
import 'package:memuno_app/src/core/failures/supabase_failure_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Maps any known backend/client error into a domain [Failure].
///
/// This mapper composes sub-mappers so the rest of the app only needs
/// a single entry point for error mapping.
final class AppFailureMapper implements FailureMapper {
  /// Creates an app-level failure mapper.
  const AppFailureMapper({
    /// Mapper for Supabase-related failures.
    required SupabaseFailureMapper supabaseFailureMapper,
  }) : _supabaseFailureMapper = supabaseFailureMapper;

  /// Handles mapping of Supabase failures.
  final SupabaseFailureMapper _supabaseFailureMapper;

  /// Maps an arbitrary [error] into a domain [Failure].
  @override
  Failure map(Object error) {
    // If we already have a Failure, return it unchanged.
    if (error is Failure) {
      return error;
    }

    if (error is SocketException || error is HandshakeException) {
      return const Failure.network();
    }

    // Only Supabase SDK exceptions should be handled by the Supabase mapper.
    if (error is supabase.AuthException ||
        error is supabase.StorageException ||
        error is supabase.PostgrestException ||
        error is supabase.FunctionException) {
      return _supabaseFailureMapper.map(error);
    }

    // Fallback for non-Supabase unknown errors.
    return Failure.unknown(message: error.toString());
  }
}
