import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum WnListItemType {
  neutral,
  success,
  warning,
  error,
}

class WnListItemAction {
  const WnListItemAction({
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
}

class WnListItemController extends ChangeNotifier {
  String? _expandedItemKey;

  String? get expandedItemKey => _expandedItemKey;

  void expand(String key) {
    if (_expandedItemKey != key) {
      _expandedItemKey = key;
      notifyListeners();
    }
  }

  void collapse() {
    if (_expandedItemKey != null) {
      _expandedItemKey = null;
      notifyListeners();
    }
  }

  bool isExpanded(String key) => _expandedItemKey == key;
}

class WnListItemScope extends InheritedNotifier<WnListItemController> {
  const WnListItemScope({
    super.key,
    required WnListItemController controller,
    required super.child,
  }) : super(notifier: controller);

  static WnListItemController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WnListItemScope>()?.notifier;
  }
}

class WnListItem extends HookWidget {
  const WnListItem({
    super.key,
    required this.title,
    this.type = WnListItemType.neutral,
    this.leadingIcon,
    this.onTap,
    this.actions,
    this.itemKey,
  });

  final String title;
  final WnListItemType type;
  final WnIcons? leadingIcon;
  final VoidCallback? onTap;
  final List<WnListItemAction>? actions;
  final String? itemKey;

  @override
  Widget build(BuildContext context) {
    final localExpanded = useState(false);
    final isPressed = useState(false);
    final colors = context.colors;
    final hasActions = actions != null && actions!.isNotEmpty;

    final controller = WnListItemScope.maybeOf(context);
    final widgetKey = key;

    String computeEffectiveKey() {
      if (itemKey != null) return itemKey!;
      if (widgetKey != null) {
        if (widgetKey is ValueKey) {
          return widgetKey.value.toString();
        }
        return widgetKey.toString();
      }
      return title;
    }

    final effectiveKey = computeEffectiveKey();

    assert(
      () {
        if (widgetKey is UniqueKey && itemKey == null) {
          throw FlutterError.fromParts([
            ErrorSummary('WnListItem with UniqueKey requires an explicit itemKey.'),
            ErrorDescription(
              'UniqueKey generates a new identity on each build, which causes '
              'expansion state to be lost. Provide an explicit itemKey parameter '
              'to ensure stable identity.',
            ),
          ]);
        }
        return true;
      }(),
    );

    final isExpanded = controller != null
        ? controller.isExpanded(effectiveKey)
        : localExpanded.value;

    void setExpanded(bool value) {
      if (controller != null) {
        if (value) {
          controller.expand(effectiveKey);
        } else {
          controller.collapse();
        }
      } else {
        localExpanded.value = value;
      }
    }

    void handleTap() {
      if (controller != null && controller.expandedItemKey != null) {
        controller.collapse();
      }
      onTap?.call();
    }

    Color getBackgroundColor() {
      if (isExpanded) {
        return colors.fillSecondaryActive;
      }
      if (isPressed.value) {
        return colors.fillSecondaryHover;
      }
      return colors.fillSecondary;
    }

    Widget? buildLeadingIcon() {
      if (type == WnListItemType.neutral) {
        if (leadingIcon == null) return null;
        return WnIcon(
          leadingIcon!,
          key: const Key('list_item_type_icon'),
          size: 20.w,
          color: colors.fillContentTertiary,
        );
      }

      final (WnIcons icon, Color color) = switch (type) {
        WnListItemType.neutral => throw StateError('Handled above'),
        WnListItemType.success => (WnIcons.checkmarkFilled, colors.intentionSuccessContent),
        WnListItemType.warning => (WnIcons.warningFilled, colors.intentionWarningContent),
        WnListItemType.error => (WnIcons.errorFilled, colors.intentionErrorContent),
      };

      return WnIcon(
        icon,
        key: const Key('list_item_type_icon'),
        size: 20.w,
        color: color,
      );
    }

    Widget buildExpandedActions() {
      return Padding(
        key: const Key('list_item_expanded_actions'),
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4.w,
          children: actions!.map((action) {
            return WnButton(
              text: action.label,
              type: action.isDestructive ? WnButtonType.destructive : WnButtonType.primary,
              size: WnButtonSize.xsmall,
              onPressed: () {
                action.onTap();
                setExpanded(false);
              },
            );
          }).toList(),
        ),
      );
    }

    final leadingIconWidget = buildLeadingIcon();

    return GestureDetector(
      onTap: handleTap,
      onTapDown: (_) => isPressed.value = true,
      onTapUp: (_) => isPressed.value = false,
      onTapCancel: () => isPressed.value = false,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.only(left: 14.w, right: 6.w),
        child: Row(
          children: [
            if (leadingIconWidget != null)
              Padding(
                key: const Key('list_item_leading'),
                padding: EdgeInsets.only(right: 8.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: leadingIconWidget,
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Text(
                  title,
                  style: context.typographyScaled.medium14.copyWith(
                    color: colors.fillContentSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (hasActions) ...[
              if (isExpanded)
                buildExpandedActions()
              else
                GestureDetector(
                  key: const Key('list_item_menu_button'),
                  onTap: () => setExpanded(true),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: SizedBox(
                      width: 18.w,
                      height: 18.h,
                      child: WnIcon(
                        WnIcons.more,
                        key: const Key('list_item_menu_icon'),
                        size: 18.w,
                        color: colors.fillContentTertiary,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
