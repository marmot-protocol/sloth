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

    final indicatorColor = _getColor(colors, type);

    return SizedBox.square(
      dimension: 16.w,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: controller.value * 2 * 3.14159265359,
            child: child,
          );
        },
        child: CircularProgressIndicator(
          key: const Key('spinner_indicator'),
          strokeWidth: 2.w,
          strokeCap: StrokeCap.round,
          color: indicatorColor,
          value: 0.75,
        ),
      ),
    );
  }

  Color _getColor(SemanticColors colors, WnSpinnerType type) {
    return switch (type) {
      WnSpinnerType.primary => colors.fillContentPrimary,
      WnSpinnerType.secondary => colors.fillContentSecondary,
      WnSpinnerType.destructive => colors.fillContentDestructive,
    };
  }
}
