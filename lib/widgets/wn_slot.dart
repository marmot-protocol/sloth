import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

class WnSlot extends StatelessWidget {
  const WnSlot({
    super.key,
    this.label = 'Slot',
    this.icon = WnIcons.retry,
    this.minHeight,
    this.minWidth,
    this.child,
  });

  final String label;
  final WnIcons icon;
  final double? minHeight;
  final double? minWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final borderColor = colors.accent.blue.contentSecondary;

    if (child != null) {
      return child!;
    }

    return CustomPaint(
      painter: DashedBorderPainter(
        color: borderColor,
        strokeWidth: 1.w,
        dashWidth: 4.w,
        dashSpace: 4.w,
        borderRadius: 8.r,
      ),
      child: Container(
        constraints: BoxConstraints(
          minHeight: minHeight ?? 104.h,
          minWidth: minWidth ?? 1.w,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundPrimary,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              WnIcon(
                icon,
                key: const Key('wn_slot_icon'),
                size: 18.w,
                color: borderColor,
              ),
              Gap(8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: borderColor,
                  letterSpacing: 0.4.sp,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class DashedBorderPainter extends CustomPainter {
  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final dashedPath = _createDashedPath(path);
    canvas.drawPath(dashedPath, paint);
  }

  Path _createDashedPath(Path source) {
    final dashedPath = Path();
    final dashArray = [dashWidth, dashSpace];

    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var drawDash = true;

      while (distance < metric.length) {
        final len = dashArray[drawDash ? 0 : 1];
        if (drawDash) {
          dashedPath.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        drawDash = !drawDash;
      }
    }

    return dashedPath;
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashSpace != oldDelegate.dashSpace ||
        borderRadius != oldDelegate.borderRadius;
  }
}
