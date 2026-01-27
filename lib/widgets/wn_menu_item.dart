import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum WnMenuItemType { primary, secondary }

class WnMenuItem extends StatelessWidget {
  const WnMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.type = WnMenuItemType.primary,
  });

  final WnIcons icon;
  final String label;
  final VoidCallback onTap;
  final WnMenuItemType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final contentColor = type == WnMenuItemType.primary
        ? colors.backgroundContentPrimary
        : colors.backgroundContentSecondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 56.h,
        child: Row(
          children: [
            SizedBox(
              width: 18.w,
              height: 18.w,
              child: WnIcon(
                icon,
                size: 18.w,
                color: contentColor,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  height: 22 / 16,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
