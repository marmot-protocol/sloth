import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart' show SvgPicture;
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart' show formatInitials;

class WnInitialsAvatar extends StatelessWidget {
  const WnInitialsAvatar({
    super.key,
    this.displayName,
    this.size,
    this.showContent = true,
  });

  final String? displayName;
  final double? size;
  final bool showContent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final avatarSize = size ?? 44.w;
    final initials = formatInitials(displayName);

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.fillSecondary,
        border: Border.all(color: colors.borderTertiary, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: showContent
          ? Center(
              child: initials != null
                  ? Text(
                      initials,
                      style: TextStyle(
                        color: colors.fillContentSecondary,
                        fontSize: avatarSize * 0.4,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : SvgPicture.asset(
                      key: const Key('avatar_fallback_icon'),
                      'assets/svgs/user.svg',
                      package: 'sloth',
                      width: avatarSize * 0.4,
                      height: avatarSize * 0.4,
                      colorFilter: ColorFilter.mode(
                        colors.fillContentSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
            )
          : null,
    );
  }
}
