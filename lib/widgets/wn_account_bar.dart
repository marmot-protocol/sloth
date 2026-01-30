import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';

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

    return Row(
      children: [
        GestureDetector(
          key: const Key('avatar_button'),
          onTap: () => Routes.pushToSettings(context),
          child: WnAvatar(
            pictureUrl: metadata?.picture,
            displayName: presentName(metadata),
          ),
        ),
        const Spacer(),
        IconButton(
          key: const Key('chat_add_button'),
          onPressed: () {
            Routes.pushToUserSearch(context);
          },
          icon: SvgPicture.asset(
            'assets/svgs/new_chat.svg',
            package: 'sloth',
            width: 24.w,
            height: 24.w,
            colorFilter: ColorFilter.mode(
              colors.backgroundContentPrimary,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
