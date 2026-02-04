import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/formatting.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_copy_card.dart';

class WnUserProfileCard extends StatelessWidget {
  const WnUserProfileCard({
    super.key,
    required this.userPubkey,
    this.metadata,
    this.onPublicKeyCopied,
    this.onPublicKeyCopyError,
  });

  final String userPubkey;
  final FlutterMetadata? metadata;
  final VoidCallback? onPublicKeyCopied;
  final VoidCallback? onPublicKeyCopyError;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayName = presentName(metadata);
    final npub = npubFromHex(userPubkey);
    final formattedNpub = formatPublicKey(npub ?? userPubkey);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        WnAvatar(
          pictureUrl: metadata?.picture,
          displayName: displayName,
          size: WnAvatarSize.large,
          color: AvatarColor.fromPubkey(userPubkey),
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
        if (metadata?.nip05 != null && metadata!.nip05!.isNotEmpty) ...[
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
        if (metadata?.about != null && metadata!.about!.isNotEmpty) ...[
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
        if (npub != null) ...[
          Gap(24.h),
          WnCopyCard(
            textToDisplay: formattedNpub,
            textToCopy: npub,
            onCopySuccess: () => onPublicKeyCopied?.call(),
            onCopyError: () => onPublicKeyCopyError?.call(),
          ),
        ],
      ],
    );
  }
}
