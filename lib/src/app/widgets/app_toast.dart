import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/src/app/theme/app_colors.dart';

/// Toast variants for user feedback.
enum AppToastVariant { info, success, warning, error }

/// Action shown inside a toast.
final class AppToastAction {
  /// Creates an AppToastAction instance.
  const AppToastAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

/// Lightweight toaster for in-app feedback.
final class AppToaster {
  static const int _maxVisible = 3;

  /// Value used for counter.
  static int _counter = 0;

  /// Value used for entry.
  static OverlayEntry? _entry;
  static _ToastStackState? _state;
  static final List<_ToastItem> _pending = <_ToastItem>[];

  /// Shows a toast overlay.
  static void show(
    BuildContext context, {
    required String message,
    AppToastVariant variant = AppToastVariant.info,
    String? title,
    AppToastAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final OverlayState? overlay =
        Overlay.maybeOf(context, rootOverlay: true) ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;
    if (overlay == null || !overlay.mounted) {
      return;
    }

    _ensureEntry(overlay);

    final _ToastItem item = _ToastItem(
      id: _counter++,
      message: message,
      variant: variant,
      title: title,
      action: action,
      duration: duration,
    );

    if (_state == null) {
      _pending.add(item);
      return;
    }

    _state?.insert(item, maxVisible: _maxVisible);
  }

  /// Ensures the toast overlay entry exists before inserting items.
  static void _ensureEntry(OverlayState overlay) {
    if (_entry != null) {
      return;
    }

    _entry = OverlayEntry(
      builder: (BuildContext context) {
        return _ToastStack(onEmpty: _removeEntry);
      },
    );

    overlay.insert(_entry!);
  }

  /// Removes and clears the active toast overlay entry.
  static void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }
}

class _ToastItem {
  /// Creates a _ToastItem instance.
  const _ToastItem({
    required this.id,
    required this.message,
    required this.variant,
    required this.duration,
    this.title,
    this.action,
  });

  final int id;
  final String? title;
  final String message;
  final AppToastVariant variant;
  final AppToastAction? action;
  final Duration duration;
}

class _ToastStack extends StatefulWidget {
  /// Creates a _ToastStack instance.
  const _ToastStack({required this.onEmpty});

  final VoidCallback onEmpty;

  @override
  /// Creates the state object for this widget.
  State<_ToastStack> createState() => _ToastStackState();
}

class _ToastStackState extends State<_ToastStack> {
  static const Duration _animationDuration = Duration(milliseconds: 220);

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<_ToastItem> _items = <_ToastItem>[];
  final Map<int, Timer> _timers = <int, Timer>{};

  @override
  /// Initializes state when the widget is inserted into the tree.
  void initState() {
    super.initState();
    AppToaster._state = this;
    if (AppToaster._pending.isNotEmpty) {
      final List<_ToastItem> pending = List<_ToastItem>.from(
        AppToaster._pending,
      );
      AppToaster._pending.clear();
      for (final _ToastItem item in pending) {
        insert(item, maxVisible: AppToaster._maxVisible);
      }
    }
  }

  @override
  /// Releases resources held by this instance.
  void dispose() {
    for (final Timer timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    if (AppToaster._state == this) {
      AppToaster._state = null;
    }
    super.dispose();
  }

  /// Inserts a toast item into the visible stack.
  void insert(_ToastItem item, {required int maxVisible}) {
    if (_items.length >= maxVisible) {
      _removeAt(_items.length - 1, animated: true);
    }

    _items.insert(0, item);
    _listKey.currentState?.insertItem(0, duration: _animationDuration);

    _timers[item.id]?.cancel();
    _timers[item.id] = Timer(item.duration, () => remove(item.id));
  }

  /// Removes a toast item by its identifier.
  void remove(int id, {bool animated = true}) {
    final int index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    _removeAt(index, animated: animated);
  }

  /// Removes the toast item at the given index.
  void _removeAt(int index, {required bool animated}) {
    final _ToastItem item = _items.removeAt(index);
    _timers.remove(item.id)?.cancel();

    _listKey.currentState?.removeItem(index, (
      BuildContext context,
      Animation<double> animation,
    ) {
      if (!animated) {
        return const SizedBox.shrink();
      }
      return _ToastTile(
        item: item,
        animation: animation,
        onClose: null,
        onSwipe: null,
        onAction: null,
      );
    }, duration: animated ? _animationDuration : Duration.zero);

    if (_items.isEmpty) {
      widget.onEmpty();
    }
  }

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    final bool isCompact = MediaQuery.of(context).size.width < 600;
    final Alignment alignment = isCompact
        ? Alignment.bottomCenter
        : Alignment.bottomRight;
    final EdgeInsets padding = isCompact
        ? const EdgeInsets.all(16)
        : const EdgeInsets.only(right: 24, bottom: 24);

    return SafeArea(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _items.length,
              reverse: true,
              shrinkWrap: true,
              itemBuilder: (context, index, animation) {
                final _ToastItem item = _items[index];
                return _ToastTile(
                  item: item,
                  animation: animation,
                  onClose: () => remove(item.id),
                  onSwipe: () => remove(item.id, animated: false),
                  onAction: item.action == null
                      ? null
                      : () {
                          item.action!.onPressed();
                          remove(item.id, animated: true);
                        },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastTile extends StatelessWidget {
  /// Creates a _ToastTile instance.
  const _ToastTile({
    required this.item,
    required this.animation,
    this.onClose,
    this.onSwipe,
    this.onAction,
  });

  final _ToastItem item;
  final Animation<double> animation;
  final VoidCallback? onClose;
  final VoidCallback? onSwipe;
  final VoidCallback? onAction;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    final CurvedAnimation curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return SizeTransition(
      sizeFactor: curved,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(curved),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Dismissible(
              key: ValueKey<int>(item.id),
              direction: DismissDirection.horizontal,
              onDismissed: (_) => onSwipe?.call(),
              child: AppToast(
                title: item.title,
                message: item.message,
                variant: item.variant,
                action: item.action,
                onAction: onAction,
                onClose: onClose,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Toast card styled to match shadcn UI.
class AppToast extends StatelessWidget {
  /// Creates an AppToast instance.
  const AppToast({
    super.key,
    required this.message,
    required this.variant,
    this.title,
    this.action,
    this.onAction,
    this.onClose,
  });

  final String? title;
  final String message;
  final AppToastVariant variant;
  final AppToastAction? action;
  final VoidCallback? onAction;
  final VoidCallback? onClose;

  @override
  /// Builds and returns the widget tree for this component.
  Widget build(BuildContext context) {
    final AppShadColors colors = AppShadColors.of(context);
    final Color accent = _accentColor(colors, variant);
    final IconData icon = _iconForVariant(variant);
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: colors.foreground.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: <Widget>[
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3,
                child: ColoredBox(color: accent),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(icon, color: accent, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (title != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                title!,
                                style: textTheme.labelLarge?.copyWith(
                                  color: colors.cardForeground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Text(
                            message,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.cardForeground,
                            ),
                          ),
                          if (action != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: TextButton(
                                onPressed: onAction,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: colors.foreground,
                                  textStyle: textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: Text(action!.label),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (onClose != null)
                      IconButton(
                        icon: Icon(
                          LucideIcons.x,
                          size: 16,
                          color: colors.mutedForeground,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        onPressed: onClose,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Resolves the accent color for the toast variant.
  Color _accentColor(AppShadColors colors, AppToastVariant variant) {
    return switch (variant) {
      AppToastVariant.info => colors.info,
      AppToastVariant.success => colors.success,
      AppToastVariant.warning => colors.warning,
      AppToastVariant.error => colors.destructive,
    };
  }

  /// Resolves the icon used for the toast variant.
  IconData _iconForVariant(AppToastVariant variant) {
    return switch (variant) {
      AppToastVariant.info => LucideIcons.info,
      AppToastVariant.success => LucideIcons.circle_check,
      AppToastVariant.warning => LucideIcons.triangle_alert,
      AppToastVariant.error => LucideIcons.circle_alert,
    };
  }
}
