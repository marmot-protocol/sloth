import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ScrollEdgeEffectType {
  canvas,
  slate,
  dropdown,
}

enum ScrollEdgePosition {
  top,
  bottom,
}

class WnScrollEdgeEffect extends StatelessWidget {
  const WnScrollEdgeEffect._({
    super.key,
    required this.type,
    required this.position,
    required this.color,
    this.height,
  });

  const WnScrollEdgeEffect.canvasTop({
    Key? key,
    required Color color,
    double? height,
  }) : this._(
         key: key,
         type: ScrollEdgeEffectType.canvas,
         position: ScrollEdgePosition.top,
         color: color,
         height: height,
       );

  const WnScrollEdgeEffect.canvasBottom({
    Key? key,
    required Color color,
    double? height,
  }) : this._(
         key: key,
         type: ScrollEdgeEffectType.canvas,
         position: ScrollEdgePosition.bottom,
         color: color,
         height: height,
       );

  const WnScrollEdgeEffect.slateTop({
    Key? key,
    required Color color,
    double? height,
  }) : this._(
         key: key,
         type: ScrollEdgeEffectType.slate,
         position: ScrollEdgePosition.top,
         color: color,
         height: height,
       );

  const WnScrollEdgeEffect.slateBottom({
    Key? key,
    required Color color,
    double? height,
  }) : this._(
         key: key,
         type: ScrollEdgeEffectType.slate,
         position: ScrollEdgePosition.bottom,
         color: color,
         height: height,
       );

  const WnScrollEdgeEffect.dropdownTop({
    Key? key,
    required Color color,
    double? height,
  }) : this._(
         key: key,
         type: ScrollEdgeEffectType.dropdown,
         position: ScrollEdgePosition.top,
         color: color,
         height: height,
       );

  const WnScrollEdgeEffect.dropdownBottom({
    Key? key,
    required Color color,
    double? height,
  }) : this._(
         key: key,
         type: ScrollEdgeEffectType.dropdown,
         position: ScrollEdgePosition.bottom,
         color: color,
         height: height,
       );

  final ScrollEdgeEffectType type;
  final ScrollEdgePosition position;
  final Color color;
  final double? height;

  double get _defaultHeight {
    switch (type) {
      case ScrollEdgeEffectType.canvas:
        return 48.h;
      case ScrollEdgeEffectType.slate:
        return 80.h;
      case ScrollEdgeEffectType.dropdown:
        return 40.h;
    }
  }

  bool get _isTop => position == ScrollEdgePosition.top;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = height ?? _defaultHeight;

    return Positioned(
      top: _isTop ? 0 : null,
      bottom: _isTop ? null : 0,
      left: 0,
      right: 0,
      height: effectiveHeight,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isTop
                  ? [color, color.withValues(alpha: 0)]
                  : [color.withValues(alpha: 0), color],
            ),
          ),
        ),
      ),
    );
  }
}
