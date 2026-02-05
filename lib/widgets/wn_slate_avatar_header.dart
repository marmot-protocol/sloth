import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';

class WnSlateAvatarHeader extends StatelessWidget {
  const WnSlateAvatarHeader({
    super.key,
    this.avatarUrl,
    this.displayName,
    this.onAvatarTap,
    this.action,
  });

  final String? avatarUrl;
  final String? displayName;
  final VoidCallback? onAvatarTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              child: WnAvatar(
                pictureUrl: avatarUrl,
                displayName: displayName,
              ),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
