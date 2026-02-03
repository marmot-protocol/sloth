import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart'
    show HookWidget, useAnimationController, useEffect;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

enum WnSpinnerType { primary, secondary, destructive }

class WnSpinner extends HookWidget {
  const WnSpinner({super.key, this.type = WnSpinnerType.primary});

  final WnSpinnerType type;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final controller = useAnimationController(
      duration: const Duration(milliseconds: 900),
    );

    useEffect(() {
      controller.repeat();
      return null;
    }, const []);

    final spinnerColors = _getColors(colors, type);

    return Semantics(
      label: 'Loading',
      child: SizedBox.square(
        dimension: 16.w,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: controller.value * 2 * pi,
              child: child,
            );
          },
          child: CustomPaint(
            key: const Key('spinner_indicator'),
            painter: SpinnerPainter(
              trackColor: spinnerColors.track,
              arcColor: spinnerColors.arc,
              strokeWidth: 3.w,
            ),
          ),
        ),
      ),
    );
  }

  ({Color track, Color arc}) _getColors(SemanticColors colors, WnSpinnerType type) {
    return switch (type) {
      WnSpinnerType.primary => (
        track: colors.borderSecondary,
        arc: colors.borderTertiary,
      ),
      WnSpinnerType.secondary => (
        track: colors.borderTertiary,
        arc: colors.borderSecondary,
      ),
      WnSpinnerType.destructive => (
        track: colors.borderDestructivePrimary,
        arc: colors.borderTertiary,
      ),
    };
  }
}

@visibleForTesting
class SpinnerPainter extends CustomPainter {
  SpinnerPainter({
    required this.trackColor,
    required this.arcColor,
    required this.strokeWidth,
  });

  final Color trackColor;
  final Color arcColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arcPaint = Paint()
      ..color = arcColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2;
    const sweepAngle = 0.625 * 2 * pi;
    canvas.drawArc(rect, startAngle, sweepAngle, false, arcPaint);
  }

  @override
  bool shouldRepaint(SpinnerPainter oldDelegate) {
    return oldDelegate.trackColor != trackColor ||
        oldDelegate.arcColor != arcColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
