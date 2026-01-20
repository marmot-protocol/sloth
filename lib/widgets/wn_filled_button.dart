import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

class WnFilledButton extends StatelessWidget {
  const WnFilledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
    this.disabled = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FilledButton(
      onPressed: (loading || disabled) ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        backgroundColor: disabled ? colors.fillPrimary.withValues(alpha: 0.9) : colors.fillPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        overlayColor: colors.fillPrimary.withValues(alpha: 0.8),
      ),
      child: loading
          ? SizedBox.square(
              dimension: 18.w,
              child: CircularProgressIndicator(
                key: const Key('loading_indicator'),
                strokeWidth: 2.w,
                strokeCap: StrokeCap.round,
                color: colors.fillContentPrimary,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: disabled
                    ? colors.fillContentPrimary.withValues(alpha: 0.9)
                    : colors.fillContentPrimary,
              ),
            ),
    );
  }
}
