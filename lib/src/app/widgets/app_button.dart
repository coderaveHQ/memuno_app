import 'package:flutter/material.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';
import 'package:memuno_app/src/app/widgets/app_loading_indicator.dart';

/// Visual variants for [AppButton].
enum AppButtonVariant { primary, secondary, bordered, destructive, ghost }

/// Common button widget aligned with the app theme.
class AppButton extends StatelessWidget {
  /// Primary call-to-action button.
  factory AppButton.primary({
    required Widget child,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
  }) {
    return AppButton._(
      variant: AppButtonVariant.primary,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      child: child,
    );
  }

  /// Secondary button used for alternative actions.
  factory AppButton.secondary({
    required Widget child,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
  }) {
    return AppButton._(
      variant: AppButtonVariant.secondary,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      child: child,
    );
  }

  /// Bordered button for low-emphasis actions.
  factory AppButton.bordered({
    required Widget child,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
  }) {
    return AppButton._(
      variant: AppButtonVariant.bordered,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      child: child,
    );
  }

  /// Destructive button for irreversible actions.
  factory AppButton.destructive({
    required Widget child,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = true,
  }) {
    return AppButton._(
      variant: AppButtonVariant.destructive,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      child: child,
    );
  }

  /// Ghost button for low-emphasis text actions.
  factory AppButton.ghost({
    required Widget child,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool fullWidth = false,
  }) {
    return AppButton._(
      variant: AppButtonVariant.ghost,
      onPressed: onPressed,
      isLoading: isLoading,
      fullWidth: fullWidth,
      child: child,
    );
  }

  /// Creates a AppButton instance.
  const AppButton._({
    required this.variant,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = true,
  });

  /// Button visual variant.
  final AppButtonVariant variant;

  /// Tap handler.
  final VoidCallback? onPressed;

  /// Button label or custom content.
  final Widget child;

  /// Whether to show a loading spinner.
  final bool isLoading;

  /// Whether to take the full width of the parent.
  final bool fullWidth;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;
    final AppShadColors colors = AppShadColors.of(context);

    final Color background = _backgroundColor(colors, variant);
    final Color foreground = _foregroundColor(colors, variant);
    final BorderSide? border = _borderSide(colors, variant);

    final Color disabledForeground = colors.mutedForeground.withValues(
      alpha: 0.6,
    );
    final bool transparentBackground =
        variant == AppButtonVariant.bordered ||
        variant == AppButtonVariant.ghost;
    final Color disabledBackground = transparentBackground
        ? Colors.transparent
        : colors.muted.withValues(alpha: 0.6);
    final BorderSide? disabledBorder = variant == AppButtonVariant.bordered
        ? BorderSide(color: colors.border.withValues(alpha: 0.6))
        : border;

    final ButtonStyle style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textStyle: WidgetStatePropertyAll(
        Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledBackground;
        }
        return background;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledForeground;
        }
        return foreground;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return colors.ring.withValues(alpha: 0.12);
        }
        return null;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledBorder;
        }
        return border;
      }),
    );

    final Widget content = isLoading
        ? AppLoadingIndicator(color: foreground)
        : child;

    final Widget button = TextButton(
      onPressed: disabled ? null : onPressed,
      style: style,
      child: content,
    );

    if (!fullWidth) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }

  /// Returns background color.
  Color _backgroundColor(AppShadColors colors, AppButtonVariant variant) {
    return switch (variant) {
      AppButtonVariant.primary => colors.primary,
      AppButtonVariant.secondary => colors.secondary,
      AppButtonVariant.bordered => Colors.transparent,
      AppButtonVariant.destructive => colors.destructive,
      AppButtonVariant.ghost => Colors.transparent,
    };
  }

  /// Returns foreground color.
  Color _foregroundColor(AppShadColors colors, AppButtonVariant variant) {
    return switch (variant) {
      AppButtonVariant.primary => colors.primaryForeground,
      AppButtonVariant.secondary => colors.secondaryForeground,
      AppButtonVariant.bordered => colors.foreground,
      AppButtonVariant.destructive => colors.destructiveForeground,
      AppButtonVariant.ghost => colors.foreground,
    };
  }

  /// Returns border side.
  BorderSide? _borderSide(AppShadColors colors, AppButtonVariant variant) {
    if (variant == AppButtonVariant.bordered) {
      return BorderSide(color: colors.border, width: 1);
    }
    return null;
  }
}
