import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_copyable_field.dart';

class WnUserProfileCard extends StatelessWidget {
  const WnUserProfileCard({
    super.key,
    required this.userPubkey,
    this.metadata,
    this.isFollowing = false,
    this.isFollowLoading = false,
    this.onFollowPressed,
    this.showFollowButton = true,
    this.additionalButtons = const [],
  });

  final String userPubkey;
  final FlutterMetadata? metadata;
  final bool isFollowing;
  final bool isFollowLoading;
  final VoidCallback? onFollowPressed;
  final bool showFollowButton;
  final List<Widget> additionalButtons;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayName = presentName(metadata);
    final npub = npubFromHex(userPubkey);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WnAvatar(
          pictureUrl: metadata?.picture,
          displayName: displayName,
          size: 80.w,
          animated: true,
        ),
        Gap(16.h),
        if (displayName != null)
          Text(
            displayName,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: colors.backgroundContentPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        if (metadata?.nip05 != null) ...[
          Gap(4.h),
          Text(
            metadata!.nip05!,
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.backgroundContentTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        if (metadata?.about != null) ...[
          Gap(16.h),
          Text(
            metadata!.about!,
            style: TextStyle(
              fontSize: 14.sp,
              color: colors.backgroundContentSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        Gap(24.h),
        if (npub != null)
          WnCopyableField(
            label: context.l10n.publicKey,
            value: npub,
            copiedMessage: context.l10n.publicKeyCopied,
          ),
        if (showFollowButton || additionalButtons.isNotEmpty) Gap(24.h),
        if (showFollowButton)
          SizedBox(
            width: double.infinity,
            child: WnButton(
              key: const Key('follow_button'),
              text: isFollowing ? context.l10n.unfollow : context.l10n.follow,
              type: isFollowing ? WnButtonType.outline : WnButtonType.primary,
              loading: isFollowLoading,
              onPressed: onFollowPressed,
            ),
          ),
        ...additionalButtons,
      ],
    );
  }
}
