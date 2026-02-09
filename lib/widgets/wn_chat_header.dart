import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';
import 'package:whitenoise/widgets/wn_icon.dart';

class WnChatHeader extends StatelessWidget {
  const WnChatHeader({
    super.key,
    required this.mlsGroupId,
    required this.displayName,
    this.pictureUrl,
    this.peerPubkey,
    required this.onBack,
    required this.onMenuTap,
  });

  final String mlsGroupId;
  final String displayName;
  final String? pictureUrl;
  final String? peerPubkey;
  final VoidCallback onBack;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      children: [
        IconButton(
          key: const Key('back_button'),
          onPressed: onBack,
          icon: WnIcon(
            WnIcons.chevronLeft,
            color: colors.backgroundContentTertiary,
            size: 28.w,
          ),
          tooltip: 'Back',
        ),
        SizedBox(width: 8.w),
        WnAvatar(
          pictureUrl: pictureUrl,
          displayName: displayName,
          color: AvatarColor.fromPubkey(peerPubkey ?? mlsGroupId),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            displayName,
            style: context.typographyScaled.semiBold16.copyWith(
              color: colors.backgroundContentPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          key: const Key('menu_button'),
          onPressed: onMenuTap,
          icon: WnIcon(
            WnIcons.more,
            color: colors.backgroundContentTertiary,
            size: 24.w,
          ),
          tooltip: 'Menu',
        ),
      ],
    );
  }
}
