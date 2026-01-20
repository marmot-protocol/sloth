import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';

class WnSlateContainer extends StatelessWidget {
  const WnSlateContainer({
    super.key,
    required this.child,
    this.tag,
    this.padding,
  });

  final Widget child;
  final String? tag;
  final EdgeInsetsGeometry? padding;

  BoxDecoration _decoration(SemanticColors colors) {
    return BoxDecoration(
      color: colors.backgroundTertiary,
      border: Border.all(color: colors.borderSecondary),
      borderRadius: BorderRadius.circular(14.r),
      boxShadow: [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.06),
          offset: const Offset(0, 2),
          blurRadius: 4,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 4),
          blurRadius: 6,
          spreadRadius: -1,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Hero(
      tag: tag ?? 'wn-slate-container',
      flightShuttleBuilder:
          (
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            return Material(
              type: MaterialType.transparency,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                padding: padding ?? EdgeInsets.all(14.w),
                decoration: _decoration(colors),
              ),
            );
          },
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          padding: padding ?? EdgeInsets.all(14.w),
          decoration: _decoration(colors),
          child: child,
        ),
      ),
    );
  }
}
