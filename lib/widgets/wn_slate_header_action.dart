import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_icon.dart';

enum WnSlateHeaderActionType { close, back }

class WnSlateHeaderAction extends StatelessWidget {
  const WnSlateHeaderAction({
    super.key,
    required this.type,
    required this.onPressed,
  });

  final WnSlateHeaderActionType type;
  final VoidCallback onPressed;

  WnIcons get _icon => switch (type) {
    WnSlateHeaderActionType.close => WnIcons.closeLarge,
    WnSlateHeaderActionType.back => WnIcons.chevronLeft,
  };

  EdgeInsetsGeometry get _padding => switch (type) {
    WnSlateHeaderActionType.back => EdgeInsets.only(left: 24.w, right: 32.w),
    _ => EdgeInsets.only(left: 32.w, right: 24.w),
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 80.h,
        padding: _padding,
        alignment: type == WnSlateHeaderActionType.back
            ? Alignment.centerLeft
            : Alignment.centerRight,
        child: WnIcon(
          _icon,
          size: 24.w,
          color: colors.backgroundContentPrimary,
        ),
      ),
    );
  }
}
