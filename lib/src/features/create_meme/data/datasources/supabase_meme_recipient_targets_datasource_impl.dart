import 'package:memuno_app/src/core/models/pagination/list_page_dto.dart';
import 'package:memuno_app/src/features/create_meme/data/datasources/meme_recipient_targets_datasource.dart';
import 'package:memuno_app/src/features/create_meme/data/dto/meme_recipient_target_item_dto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [MemeRecipientTargetsDatasource].
final class SupabaseMemeRecipientTargetsDatasourceImpl
    implements MemeRecipientTargetsDatasource {
  const SupabaseMemeRecipientTargetsDatasourceImpl({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  final SupabaseClient _supabaseClient;

  @override
  Future<ListPageDto<MemeRecipientTargetItemDto>> listRecipientTargets({
    String? search,
    required int limit,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) async {
    final Object? payload = await _supabaseClient.rpc<Object?>(
      'meme_recipient_targets_list',
      params: <String, dynamic>{
        'p_search': search,
        'p_limit': limit,
        'p_cursor_created_at': cursorCreatedAt?.toIso8601String(),
        'p_cursor_id': cursorId,
      },
    );

    if (payload is! Map) {
      throw const FormatException(
        'Expected `meme_recipient_targets_list` to return a JSON object payload.',
      );
    }

    return ListPageDto<MemeRecipientTargetItemDto>.fromJson(
      Map<String, Object?>.from(payload),
      itemFromJson: MemeRecipientTargetItemDto.fromJson,
    );
  }
}
