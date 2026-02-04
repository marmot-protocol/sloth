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

class WnListItem extends HookWidget {
  const WnListItem({
    super.key,
    required this.title,
    this.type = WnListItemType.neutral,
    this.leadingIcon,
    this.onTap,
    this.actions,
  });

  final String title;
  final WnListItemType type;
  final WnIcons? leadingIcon;
  final VoidCallback? onTap;
  final List<WnListItemAction>? actions;

  @override
  Widget build(BuildContext context) {
    final isExpanded = useState(false);
    final isPressed = useState(false);
    final colors = context.colors;
    final hasActions = actions != null && actions!.isNotEmpty;

    Color getBackgroundColor() {
      if (isExpanded.value) {
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
        padding: EdgeInsets.only(right: 8.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4.w,
          children: actions!.map((action) {
            return WnButton(
              text: action.label,
              type: action.isDestructive ? WnButtonType.destructive : WnButtonType.primary,
              size: WnButtonSize.small,
              onPressed: () {
                action.onTap();
                isExpanded.value = false;
              },
            );
          }).toList(),
        ),
      );
    }

    final leadingIconWidget = buildLeadingIcon();

    return GestureDetector(
      onTap: onTap,
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.fillContentSecondary,
                    height: 18 / 14,
                    letterSpacing: 0.4.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (hasActions) ...[
              if (isExpanded.value) buildExpandedActions(),
              GestureDetector(
                key: const Key('list_item_menu_button'),
                onTap: () => isExpanded.value = !isExpanded.value,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: WnIcon(
                      isExpanded.value ? WnIcons.closeSmall : WnIcons.more,
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
