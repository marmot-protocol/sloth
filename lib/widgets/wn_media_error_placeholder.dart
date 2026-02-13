import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/theme.dart';

class WnMediaErrorPlaceholder extends StatelessWidget {
  final VoidCallback onRetry;
  final double? width;
  final double? height;

  const WnMediaErrorPlaceholder({
    super.key,
    required this.onRetry,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: width ?? double.infinity,
      height: height ?? 200.h,
      color: colors.fillSecondary,
      child: Center(
        child: GestureDetector(
          key: const Key('retry_button'),
          onTap: onRetry,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: colors.backgroundPrimary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh,
                  key: const Key('retry_icon'),
                  size: 16.w,
                  color: colors.backgroundContentSecondary,
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: Text(
                    'Retry',
                    overflow: TextOverflow.ellipsis,
                    style: context.typographyScaled.medium12.copyWith(
                      color: colors.backgroundContentSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
