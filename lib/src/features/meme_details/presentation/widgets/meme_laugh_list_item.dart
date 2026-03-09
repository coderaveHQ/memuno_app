import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/extensions/date_time_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_avatar.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_laugh_list_page_item_entity.dart';

/// Tile widget for rendering one laughed-user list item.
class MemeLaughListItem extends StatelessWidget {
  /// Creates one meme-laugh list item tile.
  const MemeLaughListItem({super.key, required this.item});

  /// Laughed-user payload to render.
  final MemeLaughListPageItemEntity item;

  @override
  Widget build(BuildContext context) {
    return MListTile(
      leading: MAvatar(name: item.user.name, dimension: 48.0),
      title: item.user.name,
      details: item.createdAt.formatHumanReadable(),
      padding: EdgeInsets.only(
        top: MSpacing.md,
        left: context.leftPadding + MSpacing.md,
        right: context.rightPadding + MSpacing.md,
        bottom: MSpacing.md,
      ),
    );
  }
}
