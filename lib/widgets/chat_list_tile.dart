import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/src/rust/api/chat_list.dart' show ChatSummary;
import 'package:sloth/src/rust/api/groups.dart' show GroupType;
import 'package:sloth/src/rust/api/users.dart' as users_api;
import 'package:sloth/widgets/wn_animated_avatar.dart';

class ChatListTile extends HookWidget {
  final ChatSummary chatSummary;

  const ChatListTile({
    super.key,
    required this.chatSummary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDm = chatSummary.groupType == GroupType.directMessage;
    final isPending = chatSummary.pendingConfirmation;
    final hasWelcomer = chatSummary.welcomerPubkey != null;

    final welcomerMetadata = useMemoized(
      () async {
        if (!isPending || !hasWelcomer) return null;

        final metadata = await users_api.userMetadata(
          pubkey: chatSummary.welcomerPubkey!,
          blockingDataSync: false,
        );

        if (metadata.name != null || metadata.displayName != null || metadata.picture != null) {
          return metadata;
        }

        return users_api.userMetadata(
          pubkey: chatSummary.welcomerPubkey!,
          blockingDataSync: true,
        );
      },
      [chatSummary.welcomerPubkey, isPending, hasWelcomer],
    );
    final welcomerSnapshot = useFuture(welcomerMetadata);

    final hasGroupName = chatSummary.name?.isNotEmpty ?? false;
    final defaultTitle = isDm ? 'Unknown user' : 'Unknown group';
    final defaultSubtitle = isDm
        ? 'Has invited you to a secure chat'
        : 'You have been invited to a secure chat';
    final welcomerName = welcomerSnapshot.data?.displayName ?? welcomerSnapshot.data?.name;

    final String title;
    final String? pictureUrl;
    final String subtitle;
    final String? avatarName;

    if (isPending) {
      if (isDm) {
        title = welcomerName ?? 'Unknown user';
        pictureUrl = welcomerSnapshot.data?.picture;
        avatarName = welcomerName;
        subtitle = 'Has invited you to a secure chat';
      } else {
        title = hasGroupName ? chatSummary.name! : 'Unknown group';
        pictureUrl = chatSummary.groupImagePath;
        avatarName = hasGroupName ? chatSummary.name! : null;
        if (welcomerSnapshot.hasData) {
          subtitle = '$welcomerName has invited you to a secure chat';
        } else {
          subtitle = 'You have been invited to a secure chat';
        }
      }
    } else {
      if (isDm) {
        title = hasGroupName ? chatSummary.name! : 'Unknown user';
        pictureUrl = chatSummary.groupImageUrl;
      } else {
        title = hasGroupName ? chatSummary.name! : 'Unknown group';
        pictureUrl = chatSummary.groupImagePath;
      }
      avatarName = hasGroupName ? chatSummary.name! : null;
      subtitle = chatSummary.lastMessage?.content ?? '';
    }

    // Debug: show timestamps to compare
    final lastMsgCreatedAt = chatSummary.lastMessage?.createdAt;
    final chatCreatedAt = chatSummary.createdAt;
    final debugInfo =
        'lastMsg: ${lastMsgCreatedAt?.toIso8601String() ?? "null"} | createdAt: ${chatCreatedAt.toIso8601String()}';

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: ListTile(
        onTap: isPending
            ? () => Routes.pushToInvite(context, chatSummary.mlsGroupId)
            : () => Routes.goToChat(context, chatSummary.mlsGroupId),
        leading: WnAnimatedAvatar(
          pictureUrl: pictureUrl,
          displayName: avatarName,
        ),
        title: Text(
          title,
          style: TextStyle(color: colors.foregroundPrimary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: TextStyle(color: colors.foregroundTertiary),
            ),
            Text(
              debugInfo,
              style: TextStyle(color: colors.foregroundTertiary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
