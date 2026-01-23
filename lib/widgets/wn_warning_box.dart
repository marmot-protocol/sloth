import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

class WnWarningBox extends StatelessWidget {
  const WnWarningBox({
    super.key,
    required this.title,
    required this.description,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.titleColor,
    this.descriptionColor,
    this.icon = WnIcons.warning,
  });

  final String title;
  final String description;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? titleColor;
  final Color? descriptionColor;
  final WnIcons icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = backgroundColor ?? colors.fillDestructive.withValues(alpha: 0.1);
    final border = borderColor ?? colors.borderDestructivePrimary;
    final iconC = iconColor ?? colors.fillDestructive;
    final titleC = titleColor ?? colors.fillDestructive;
    final descC = descriptionColor ?? colors.backgroundContentPrimary;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              WnIcon(
                icon,
                size: 20.w,
                color: iconC,
              ),
              Gap(8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: titleC,
                  ),
                ),
              ),
            ],
          ),
          Gap(8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: descC,
            ),
          ),
        ],
      ),
    );
  }
}
