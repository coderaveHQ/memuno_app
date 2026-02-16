import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';

/// App-wide top app bar aligned with the shadcn zinc theme.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates the app bar.
  const AppAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.actions,
  });

  /// Title shown in the bar.
  final String title;

  /// Optional subtitle shown under the title.
  final String? subtitle;

  /// Optional back action. When provided, a back button is shown.
  final VoidCallback? onBack;

  /// Optional trailing actions.
  final List<Widget>? actions;

  bool get _hasSubtitle => subtitle != null && subtitle!.trim().isNotEmpty;

  @override
  Size get preferredSize =>
      Size.fromHeight(_hasSubtitle ? 120 : kToolbarHeight + 8);

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    final AppShadColors colors = AppShadColors.of(context);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.foreground,
            ),
          ),
          if (_hasSubtitle) ...<Widget>[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: textTheme.bodyMedium?.copyWith(
                color: colors.mutedForeground,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      toolbarHeight: _hasSubtitle ? 120 : kToolbarHeight + 8,
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: onBack == null
          ? null
          : IconButton(
              icon: const Icon(LucideIcons.arrow_left, size: 20),
              onPressed: onBack,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
      actions: actions,
      backgroundColor: colors.background,
      foregroundColor: colors.foreground,
      surfaceTintColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
    );
  }
}
