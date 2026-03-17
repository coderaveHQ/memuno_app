import 'package:memuno_app/src/features/create_meme/data/mappers/meme_recipient_target_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_recipient_target_mapper_provider.g.dart';

/// Provides the recipient-target mapper.
@riverpod
MemeRecipientTargetMapper memeRecipientTargetMapper(Ref ref) {
  return const MemeRecipientTargetMapper();
}
