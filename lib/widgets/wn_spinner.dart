import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

enum WnSpinnerSize { small, medium, large }

class WnSpinner extends StatelessWidget {
  const WnSpinner({
    super.key,
    this.size = WnSpinnerSize.medium,
    this.color,
    this.label,
  });

  final WnSpinnerSize size;
  final Color? color;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final indicatorColor = color ?? colors.backgroundContentPrimary;
    final dimension = _getDimension();
    final strokeWidth = _getStrokeWidth();

    final indicator = SizedBox.square(
      dimension: dimension,
      child: CircularProgressIndicator(
        key: const Key('spinner_indicator'),
        strokeWidth: strokeWidth,
        strokeCap: StrokeCap.round,
        color: indicatorColor,
      ),
    );

    if (label == null) {
      return indicator;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        indicator,
        SizedBox(height: 8.h),
        Text(
          label!,
          style: TextStyle(
            fontSize: _getLabelFontSize(),
            color: colors.backgroundContentSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  double _getDimension() {
    return switch (size) {
      WnSpinnerSize.small => 16.w,
      WnSpinnerSize.medium => 24.w,
      WnSpinnerSize.large => 32.w,
    };
  }

  double _getStrokeWidth() {
    return switch (size) {
      WnSpinnerSize.small => 2.w,
      WnSpinnerSize.medium => 2.5.w,
      WnSpinnerSize.large => 3.w,
    };
  }

  double _getLabelFontSize() {
    return switch (size) {
      WnSpinnerSize.small => 12.sp,
      WnSpinnerSize.medium => 14.sp,
      WnSpinnerSize.large => 16.sp,
    };
  }
}
