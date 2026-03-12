import 'package:flutter/material.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/create_meme/domain/entities/meme_text_layer_entity.dart';

/// Focus-only mini bar for text-layer color and outline actions.
final class MemeEditorControls extends StatelessWidget {
  /// Creates focus-only controls for the currently edited text layer.
  const MemeEditorControls({
    super.key,
    required this.l10n,
    required this.layer,
    required this.onTextColorChanged,
    required this.onToggleTextBackground,
  });

  static const List<int> _textColorValues = <int>[0xFFFFFFFF, 0xFF000000];

  /// Localized strings used by the controls.
  final AppLocalizations l10n;

  /// Currently edited text layer.
  final MemeTextLayerEntity layer;

  /// Called when the text color should change.
  final ValueChanged<int> onTextColorChanged;

  /// Called when text outline should be toggled.
  final VoidCallback onToggleTextBackground;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MColors.gray100,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.all(MSpacing.sm),
      child: Row(
        children: <Widget>[
          ..._textColorValues.map(
            (int value) => Padding(
              padding: const EdgeInsets.only(right: MSpacing.xs),
              child: _MemeColorSwatch(
                colorValue: value,
                isSelected: layer.textColorValue == value,
                onTap: () => onTextColorChanged(value),
              ),
            ),
          ),
          const Spacer(),
          MButton.secondary(
            title: layer.hasBackground
                ? l10n.memeEditorTextBackgroundDisable
                : l10n.memeEditorTextBackgroundEnable,
            onPressed: onToggleTextBackground,
            isExpanded: false,
          ),
        ],
      ),
    );
  }
}

/// Selectable color chip used by the mini editor bar.
final class _MemeColorSwatch extends StatelessWidget {
  /// Creates one selectable color chip.
  const _MemeColorSwatch({
    required this.colorValue,
    required this.isSelected,
    required this.onTap,
  });

  /// ARGB color represented by this chip.
  final int colorValue;

  /// Whether this chip is currently selected.
  final bool isSelected;

  /// Called when this chip is selected.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          color: Color(colorValue),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? MColors.gray900 : MColors.gray500,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
      ),
    );
  }
}
