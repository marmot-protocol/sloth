import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

class WnOutlinedButton extends StatelessWidget {
  const WnOutlinedButton({
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

    return OutlinedButton(
      onPressed: (loading || disabled) ? null : onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        side: BorderSide(
          color: disabled ? colors.borderTertiary : colors.borderSecondary,
        ),
        backgroundColor: colors.backgroundPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        overlayColor: colors.backgroundPrimary.withValues(alpha: 0.8),
      ),
      child: loading
          ? SizedBox.square(
              dimension: 18.w,
              child: CircularProgressIndicator(
                key: const Key('loading_indicator'),
                strokeWidth: 2.w,
                strokeCap: StrokeCap.round,
                color: colors.backgroundContentPrimary,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: disabled
                    ? colors.backgroundContentPrimary.withValues(alpha: 0.5)
                    : colors.backgroundContentPrimary,
              ),
            ),
    );
  }
}
