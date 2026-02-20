import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_slider.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/app/widgets/m/m_text_field.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';

/// Editor controls for adding, editing, and deleting text layers.
final class MemeEditorControls extends StatelessWidget {
  /// Creates editor controls.
  const MemeEditorControls({
    super.key,
    required this.l10n,
    required this.selectedLayer,
    required this.selectedTextController,
    required this.selectedTextFocusNode,
    required this.onAddText,
    required this.onDeleteSelectedText,
    required this.onFontSizeChanged,
  });

  /// Localized strings for the editor controls.
  final AppLocalizations l10n;

  /// Currently selected text layer.
  final MemeTextLayerEntity? selectedLayer;

  /// Text controller bound to selected layer text.
  final TextEditingController selectedTextController;

  /// Focus node bound to selected layer text field.
  final FocusNode selectedTextFocusNode;

  /// Called when a new text layer should be inserted.
  final VoidCallback onAddText;

  /// Called when selected text layer should be removed.
  final VoidCallback onDeleteSelectedText;

  /// Called when selected-layer font size changes.
  final ValueChanged<double> onFontSizeChanged;

  @override
  Widget build(BuildContext context) {
    final MemeTextLayerEntity? layer = selectedLayer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: MButton.secondary(
                title: l10n.memeEditorAddTextButton,
                onPressed: onAddText,
              ),
            ),
            const MGap.sm(),
            MIconButton.destructive(
              icon: LucideIcons.trash_2,
              onPressed: layer == null ? null : onDeleteSelectedText,
              isEnabled: layer != null,
            ),
          ],
        ),
        if (layer != null) ...<Widget>[
          const MGap.sm(),
          MTextField(
            controller: selectedTextController,
            focusNode: selectedTextFocusNode,
            inputType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            label: l10n.memeEditorTextLabel,
            hint: l10n.memeEditorTextHint,
            maxLength: 60,
            minLines: 1,
            maxLines: 4,
          ),
          Row(
            children: <Widget>[
              const Icon(LucideIcons.type, color: MColors.gray400, size: 18.0),
              const MGap.sm(),
              Expanded(
                child: MSlider(
                  minValue: 18.0,
                  maxValue: 64.0,
                  value: layer.fontSize.clamp(18.0, 64.0),
                  onChanged: onFontSizeChanged,
                ),
              ),
              SizedBox(
                width: 34.0,
                child: MText.small(
                  text: layer.fontSize.toStringAsFixed(0),
                  alignment: TextAlign.right,
                  style: const TextStyle(color: MColors.gray300),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
