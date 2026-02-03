import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

enum WnSpinnerType { primary, secondary, destructive }

class WnSpinner extends StatefulWidget {
  const WnSpinner({super.key, this.type = WnSpinnerType.primary});

  final WnSpinnerType type;

  @override
  State<WnSpinner> createState() => _WnSpinnerState();
}

class _WnSpinnerState extends State<WnSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final indicatorColor = _getColor(colors);

    return SizedBox.square(
      dimension: 16.w,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * 3.14159265359,
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

  Color _getColor(SemanticColors colors) {
    return switch (widget.type) {
      WnSpinnerType.primary => colors.fillContentPrimary,
      WnSpinnerType.secondary => colors.fillContentSecondary,
      WnSpinnerType.destructive => colors.fillContentDestructive,
    };
  }
}
