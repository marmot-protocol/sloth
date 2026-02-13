import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:whitenoise/hooks/use_user_metadata.dart';
import 'package:whitenoise/providers/account_pubkey_provider.dart';
import 'package:whitenoise/routes.dart';
import 'package:whitenoise/theme.dart';
import 'package:whitenoise/utils/metadata.dart';
import 'package:whitenoise/widgets/wn_avatar.dart';
import 'package:whitenoise/widgets/wn_icon.dart';
import 'package:whitenoise/widgets/wn_slate_avatar_header.dart';

class ChatListHeader extends HookConsumerWidget {
  const ChatListHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final metadataSnapshot = useUserMetadata(context, pubkey);

    final metadata = metadataSnapshot.data;

    return WnSlateAvatarHeader(
      avatarKey: const Key('avatar_button'),
      avatarUrl: metadata?.picture,
      displayName: presentName(metadata),
      avatarColor: AvatarColor.fromPubkey(pubkey),
      onAvatarTap: () => Routes.pushToSettings(context),
      action: GestureDetector(
        key: const Key('chat_add_button'),
        onTap: () => Routes.pushToUserSearch(context),
        behavior: HitTestBehavior.opaque,
        child: WnIcon(WnIcons.newChat, size: 24.w, color: colors.backgroundContentPrimary),
      ),
    );
  }
}
