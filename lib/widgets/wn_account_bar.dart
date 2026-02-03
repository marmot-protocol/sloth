import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/hooks/use_user_metadata.dart';
import 'package:whitenoise/providers/account_pubkey_provider.dart';
import 'package:whitenoise/routes.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/utils/metadata.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';

class WnAccountBar extends HookConsumerWidget {
  const WnAccountBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final metadataSnapshot = useUserMetadata(context, pubkey);

    final metadata = metadataSnapshot.data;

    return SizedBox(
      height: 80.h,
      child: Row(
        children: [
          GestureDetector(
            key: const Key('avatar_button'),
            onTap: () => Routes.pushToSettings(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 80.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              alignment: Alignment.center,
              child: WnAvatar(
                pictureUrl: metadata?.picture,
                displayName: presentName(metadata),
                color: AvatarColor.fromPubkey(pubkey),
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            key: const Key('chat_add_button'),
            onTap: () => Routes.pushToUserSearch(context),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 80.h,
              padding: EdgeInsets.only(left: 32.w, right: 24.w),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/svgs/new_chat.svg',
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(
                  colors.backgroundContentPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
