import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum WnMenuItemType { primary, secondary, destructive }

class WnMenuItem extends HookWidget {
  const WnMenuItem({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.type = WnMenuItemType.primary,
  });

  final String label;
  final VoidCallback? onTap;
  final WnIcons? icon;
  final WnMenuItemType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isHovered = useState(false);
    final isPressed = useState(false);
    final isActive = isHovered.value || isPressed.value;
    final contentColor = _getContentColor(colors, isActive);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        onTapDown: (_) => isPressed.value = true,
        onTapUp: (_) => isPressed.value = false,
        onTapCancel: () => isPressed.value = false,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 56.h,
          child: Row(
            children: [
              if (icon != null)
                Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: WnIcon(
                    icon!,
                    size: 18.w,
                    color: contentColor,
                    key: const Key('menu_item_icon'),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: contentColor,
                      letterSpacing: 0.2.sp,
                      height: 22 / 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getContentColor(SemanticColors colors, bool isActive) {
    return switch (type) {
      WnMenuItemType.primary =>
        isActive ? colors.backgroundContentSecondary : colors.backgroundContentPrimary,
      WnMenuItemType.secondary =>
        isActive ? colors.backgroundContentTertiary : colors.backgroundContentSecondary,
      WnMenuItemType.destructive =>
        isActive
            ? colors.backgroundContentDestructiveSecondary
            : colors.backgroundContentDestructive,
    };
  }
}
