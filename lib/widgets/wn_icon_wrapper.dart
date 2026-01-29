import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme.dart';
import 'wn_icon.dart';

enum WnIconWrapperSize {
  size14(14),
  size16(16),
  size18(18),
  size20(20),
  size24(24),
  size32(32);

  const WnIconWrapperSize(this._iconSize);
  final int _iconSize;

  double get scaled => _iconSize.w;
}

class WnIconWrapper extends StatelessWidget {
  const WnIconWrapper({
    super.key,
    required this.icon,
    required this.accentColor,
    this.size = WnIconWrapperSize.size20,
  });

  final WnIcons icon;
  final AccentColorSet accentColor;
  final WnIconWrapperSize size;

  static const double _containerSize = 36;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _containerSize.w,
      height: _containerSize.w,
      decoration: BoxDecoration(
        color: accentColor.fill,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: WnIcon(
          icon,
          size: size.scaled,
          color: accentColor.contentSecondary,
        ),
      ),
    );
  }
}
