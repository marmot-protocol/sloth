import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_scroll_edge_effect.dart';
import 'package:sloth/widgets/wn_slate_header.dart';

enum WnSlateType { defaultType, close, back, noHeader }

class WnSlate extends StatelessWidget {
  const WnSlate({
    super.key,
    this.type = WnSlateType.defaultType,
    this.tag = 'wn-slate',
    this.title,
    this.avatarUrl,
    this.padding,
    this.onAvatarTap,
    this.onNewChatTap,
    this.onCloseTap,
    this.onBackTap,
    this.showTopScrollEffect = false,
    this.showBottomScrollEffect = false,
    this.child,
  });

  final WnSlateType type;
  final String tag;
  final String? title;
  final String? avatarUrl;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onNewChatTap;
  final VoidCallback? onCloseTap;
  final VoidCallback? onBackTap;
  final bool showTopScrollEffect;
  final bool showBottomScrollEffect;
  final Widget? child;

  WnSlateHeaderType? get _headerType => switch (type) {
    WnSlateType.defaultType => WnSlateHeaderType.defaultType,
    WnSlateType.close => WnSlateHeaderType.close,
    WnSlateType.back => WnSlateHeaderType.back,
    WnSlateType.noHeader => null,
  };

  BoxDecoration _decoration(SemanticColors colors) {
    return BoxDecoration(
      color: colors.backgroundPrimary,
      borderRadius: BorderRadius.circular(16.r),
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final headerType = _headerType;

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
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (headerType != null)
                      WnSlateHeader(
                        type: headerType,
                        title: title,
                        avatarUrl: avatarUrl,
                        onAvatarTap: onAvatarTap,
                        onNewChatTap: onNewChatTap,
                        onCloseTap: onCloseTap,
                        onBackTap: onBackTap,
                      ),
                    if (child != null) child!,
                  ],
                ),
                if (showTopScrollEffect)
                  WnScrollEdgeEffect.slateTop(color: colors.backgroundPrimary),
                if (showBottomScrollEffect)
                  WnScrollEdgeEffect.slateBottom(color: colors.backgroundPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
