import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum WnSlateNavigationType { close, back }

class WnSlateNavigationHeader extends StatelessWidget {
  const WnSlateNavigationHeader({
    super.key,
    required this.title,
    this.type = WnSlateNavigationType.close,
    this.onNavigate,
  });

  final String title;
  final WnSlateNavigationType type;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isBack = type == WnSlateNavigationType.back;
    final hasAction = onNavigate != null;
    final hasLeadingAction = isBack && hasAction;
    final hasTrailingAction = !isBack && hasAction;

    return SizedBox(
      height: 80.h,
      child: Row(
        children: [
          if (hasLeadingAction)
            _SlateHeaderAction(
              isBack: true,
              onPressed: onNavigate!,
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: hasTrailingAction ? 80.w : 0,
                right: hasLeadingAction ? 80.w : 0,
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    height: 22 / 16,
                    letterSpacing: 0.2.sp,
                    color: colors.backgroundContentPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          if (hasTrailingAction)
            _SlateHeaderAction(
              isBack: false,
              onPressed: onNavigate!,
            ),
        ],
      ),
    );
  }
}

class _SlateHeaderAction extends StatelessWidget {
  const _SlateHeaderAction({
    required this.isBack,
    required this.onPressed,
  });

  final bool isBack;
  final VoidCallback onPressed;

  WnIcons get _icon => isBack ? WnIcons.chevronLeft : WnIcons.closeLarge;

  EdgeInsetsGeometry get _padding =>
      isBack ? EdgeInsets.only(left: 24.w, right: 32.w) : EdgeInsets.only(left: 32.w, right: 24.w);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 80.h,
        padding: _padding,
        alignment: isBack ? Alignment.centerLeft : Alignment.centerRight,
        child: WnIcon(
          _icon,
          size: 24.w,
          color: colors.backgroundContentSecondary,
        ),
      ),
    );
  }
}
