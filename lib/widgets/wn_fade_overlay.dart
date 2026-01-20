import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WnFadeOverlay extends StatelessWidget {
  const WnFadeOverlay._({
    super.key,
    required this.color,
    required this.isTop,
    this.height,
  });

  const WnFadeOverlay.top({
    Key? key,
    required Color color,
    double? height,
  }) : this._(key: key, color: color, isTop: true, height: height);

  const WnFadeOverlay.bottom({
    Key? key,
    required Color color,
    double? height,
  }) : this._(key: key, color: color, isTop: false, height: height);

  final Color color;
  final bool isTop;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? 20.h;

    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0,
      right: 0,
      height: effectiveHeight,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isTop
                  ? [color, color.withValues(alpha: 0)]
                  : [color.withValues(alpha: 0), color],
            ),
          ),
        ),
      ),
    );
  }
}
