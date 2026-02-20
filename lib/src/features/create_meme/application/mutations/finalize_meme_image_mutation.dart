import 'dart:typed_data';

import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'finalize_meme_image_mutation.g.dart';

/// Mutation: finalize the current meme editor canvas into image bytes.
@riverpod
Mutation<Uint8List> finalizeMemeImageMutation(Ref ref) {
  return Mutation<Uint8List>(label: 'finalize_meme_image');
}
