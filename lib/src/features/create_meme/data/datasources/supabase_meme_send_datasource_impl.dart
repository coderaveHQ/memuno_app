import 'dart:typed_data';

import 'package:memuno_app/src/features/create_meme/data/datasources/meme_send_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [MemeSendDatasource].
final class SupabaseMemeSendDatasourceImpl implements MemeSendDatasource {
  /// Creates the datasource.
  const SupabaseMemeSendDatasourceImpl({required SupabaseClient supabaseClient})
    : _supabaseClient = supabaseClient;

  /// Supabase client used for storage and RPC operations.
  final SupabaseClient _supabaseClient;

  /// Storage bucket for finalized meme images.
  static const String _memesBucket = 'memes';

  @override
  /// Uploads bytes to storage and persists the meme via `meme_create` RPC.
  Future<void> sendMeme({
    required Uint8List memeBytes,

    /// Optional template id for built-in templates. Null for gallery images.
    required String? templateId,
    required double aspectRatio,
    required List<String> recipientUserIds,
  }) async {
    final String? userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null || userId.isEmpty) {
      throw const AuthException('Not authenticated.');
    }

    final String imagePath = _buildImagePath(userId);
    bool hasUploadedImage = false;

    try {
      await _supabaseClient.storage
          .from(_memesBucket)
          .uploadBinary(
            imagePath,
            memeBytes,
            fileOptions: const FileOptions(
              contentType: 'image/png',
              upsert: false,
            ),
          );
      hasUploadedImage = true;

      await _supabaseClient.rpc<void>(
        'meme_create',
        params: <String, dynamic>{
          'p_image_path': imagePath,
          'p_template_id': templateId,
          'p_aspect_ratio': aspectRatio,
          'p_recipient_ids': recipientUserIds,
        },
      );
    } catch (error) {
      if (hasUploadedImage) {
        await _tryDeleteUploadedImage(imagePath);
      }
      rethrow;
    }
  }

  /// Builds one unique storage path for a meme image.
  String _buildImagePath(String userId) {
    final int micros = DateTime.now().microsecondsSinceEpoch;
    return '$userId/$micros.png';
  }

  /// Best-effort cleanup for uploads when RPC fails after storage write.
  Future<void> _tryDeleteUploadedImage(String imagePath) async {
    try {
      await _supabaseClient.storage.from(_memesBucket).remove(<String>[
        imagePath,
      ]);
    } catch (_) {
      // Intentionally ignored: original failure should be surfaced to caller.
    }
  }
}
