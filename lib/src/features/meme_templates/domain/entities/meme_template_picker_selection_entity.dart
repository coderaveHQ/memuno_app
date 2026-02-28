import 'package:memuno_app/src/features/meme_templates/domain/entities/meme_template_entity.dart';
import 'package:memuno_app/src/features/meme_templates/domain/entities/picked_meme_template_image_entity.dart';

/// Selection payload returned by the meme-template picker bottom sheet.
final class MemeTemplatePickerSelectionEntity {
  /// Creates a selection for a built-in [template].
  const MemeTemplatePickerSelectionEntity.template({
    required MemeTemplateEntity template,
  }) : _template = template,
       _pickedImage = null;

  /// Creates a selection for a picked gallery [pickedImage].
  const MemeTemplatePickerSelectionEntity.gallery({
    required PickedMemeTemplateImageEntity pickedImage,
  }) : _template = null,
       _pickedImage = pickedImage;

  /// Selected built-in template payload.
  final MemeTemplateEntity? _template;

  /// Selected gallery-image payload.
  final PickedMemeTemplateImageEntity? _pickedImage;

  /// Returns selected built-in meme template, if any.
  MemeTemplateEntity? get template => _template;

  /// Returns selected picked gallery image, if any.
  PickedMemeTemplateImageEntity? get pickedImage => _pickedImage;

  /// Returns whether the selection is a built-in template.
  bool get isTemplate => _template != null;

  /// Returns whether the selection is a picked gallery image.
  bool get isGalleryImage => _pickedImage != null;
}
