import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

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
    this.showIcon = false,
    this.onTap,
    this.actions,
  });

  final String title;
  final WnListItemType type;
  final bool showIcon;
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
      if (!showIcon) return null;

      final (IconData icon, Color color) = switch (type) {
        WnListItemType.neutral => (Icons.circle_outlined, colors.fillContentTertiary),
        WnListItemType.success => (Icons.check_circle, colors.intentionSuccessContent),
        WnListItemType.warning => (Icons.warning, colors.intentionWarningContent),
        WnListItemType.error => (Icons.error, colors.intentionErrorContent),
      };

      return Icon(
        icon,
        key: const Key('list_item_type_icon'),
        size: 20.w,
        color: color,
      );
    }

    Widget buildExpandedActions() {
      return Row(
        key: const Key('list_item_expanded_actions'),
        mainAxisSize: MainAxisSize.min,
        spacing: 4.w,
        children: actions!.map((action) {
          return GestureDetector(
            onTap: () {
              action.onTap();
              isExpanded.value = false;
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 32.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: action.isDestructive ? colors.fillDestructive : colors.fillPrimary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              alignment: Alignment.center,
              child: Text(
                action.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: action.isDestructive
                      ? colors.fillContentDestructive
                      : colors.fillContentPrimary,
                  height: 18 / 14,
                  letterSpacing: 0.4.sp,
                ),
              ),
            ),
          );
        }).toList(),
      );
    }

    final leadingIcon = buildLeadingIcon();

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
            if (leadingIcon != null)
              Padding(
                key: const Key('list_item_leading'),
                padding: EdgeInsets.only(right: 8.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: leadingIcon,
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
            if (isExpanded.value && hasActions)
              buildExpandedActions()
            else if (hasActions)
              GestureDetector(
                key: const Key('list_item_menu_button'),
                onTap: () => isExpanded.value = true,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: SizedBox(
                    width: 18.w,
                    height: 18.h,
                    child: Icon(
                      Icons.more_vert,
                      key: const Key('list_item_menu_icon'),
                      size: 18.w,
                      color: colors.fillContentTertiary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
