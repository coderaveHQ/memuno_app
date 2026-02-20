import 'package:memuno_app/src/features/meme_templates/data/mappers/meme_template_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_template_mapper_provider.g.dart';

/// Provides [MemeTemplateMapper].
@Riverpod(keepAlive: true)
MemeTemplateMapper memeTemplateMapper(Ref ref) {
  return const MemeTemplateMapper();
}
