import 'package:memuno_app/src/features/meme_details/data/mappers/meme_details_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_details_mapper_provider.g.dart';

/// Provides [MemeDetailsMapper].
@Riverpod(keepAlive: true)
MemeDetailsMapper memeDetailsMapper(Ref ref) {
  return const MemeDetailsMapper();
}
