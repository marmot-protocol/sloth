import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_scroll_edge_effect.dart';
import 'package:sloth/widgets/wn_slate_content_transition.dart';

class WnSlate extends StatelessWidget {
  const WnSlate({
    super.key,
    this.tag = 'wn-slate',
    this.header,
    this.padding,
    this.showTopScrollEffect = false,
    this.showBottomScrollEffect = false,
    this.systemNotice,
    this.child,
    this.animateContent = true,
  });

  final String tag;
  final Widget? header;
  final EdgeInsetsGeometry? padding;
  final bool showTopScrollEffect;
  final bool showBottomScrollEffect;
  final Widget? systemNotice;
  final Widget? child;
  final bool animateContent;

  BoxDecoration _decoration(SemanticColors colors) {
    return BoxDecoration(
      color: colors.backgroundSecondary,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: colors.borderTertiary),
      boxShadow: [
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 2,
          spreadRadius: -1,
        ),
        BoxShadow(
          color: colors.shadow.withValues(alpha: 0.1),
          offset: const Offset(0, 1),
          blurRadius: 3,
        ),
      ],
    );
  }

  Widget _buildContent(SemanticColors colors) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null) header!,
            if (child != null) Flexible(child: child!),
            if (systemNotice != null) systemNotice!,
          ],
        ),
        if (showTopScrollEffect) WnScrollEdgeEffect.slateTop(color: colors.backgroundSecondary),
        if (showBottomScrollEffect)
          WnScrollEdgeEffect.slateBottom(color: colors.backgroundSecondary),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final route = ModalRoute.of(context);
    final animation = route?.animation ?? kAlwaysCompleteAnimation;

    final content = _buildContent(colors);

    return Hero(
      tag: tag,
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
                padding: padding,
                decoration: _decoration(colors),
              ),
            );
          },
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          padding: padding,
          decoration: _decoration(colors),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: animateContent
                ? WnSlateContentTransition(
                    routeAnimation: animation,
                    child: content,
                  )
                : content,
          ),
        ),
      ),
    );
  }
}
