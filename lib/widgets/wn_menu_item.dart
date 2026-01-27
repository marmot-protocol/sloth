import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum WnMenuItemType { primary, secondary, destructive }

class WnMenuItem extends StatelessWidget {
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
    final contentColor = _getContentColor(colors);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        hoverColor: colors.fillTertiaryHover,
        splashColor: colors.fillTertiaryActive,
        child: Container(
          height: 56.h,
          padding: EdgeInsets.zero,
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
                      letterSpacing: 0.2,
                      height: 22 / 16,
                    ),
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

  Color _getContentColor(SemanticColors colors) {
    return switch (type) {
      WnMenuItemType.primary => colors.backgroundContentPrimary,
      WnMenuItemType.secondary => colors.backgroundContentSecondary,
      WnMenuItemType.destructive => colors.backgroundContentDestructive,
    };
  }
}
