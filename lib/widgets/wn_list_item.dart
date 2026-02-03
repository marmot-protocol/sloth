import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

class WnListItem extends StatelessWidget {
  const WnListItem({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: colors.fillSecondary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.only(left: 14.w, right: 6.w),
        child: Row(
          children: [
            if (leading != null)
              Padding(
                key: const Key('list_item_leading'),
                padding: EdgeInsets.only(right: 8.w),
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: leading,
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
            if (trailing != null)
              Padding(
                key: const Key('list_item_trailing'),
                padding: EdgeInsets.only(right: 8.w),
                child: SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: trailing,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
