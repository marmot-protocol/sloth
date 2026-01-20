import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/services/user_metadata_service.dart';
import 'package:sloth/src/rust/api/chat_list.dart' show ChatSummary;
import 'package:sloth/src/rust/api/groups.dart' show GroupType;
import 'package:sloth/theme.dart';
import 'package:sloth/utils/metadata.dart';
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

        try {
          return UserMetadataService(chatSummary.welcomerPubkey!).fetch();
        } catch (_) {
          return null;
        }
      },
      [chatSummary.welcomerPubkey, isPending, hasWelcomer],
    );
    final welcomerSnapshot = useFuture(welcomerMetadata);

    final hasGroupName = chatSummary.name?.isNotEmpty ?? false;
    final welcomerName = presentName(welcomerSnapshot.data);

    final String title;
    final String? pictureUrl;
    final String subtitle;
    final String? avatarName;

    if (isPending) {
      if (isDm) {
        title = welcomerName ?? chatSummary.name ?? 'Unknown user';
        pictureUrl = welcomerSnapshot.data?.picture ?? chatSummary.groupImageUrl;
        avatarName = welcomerName ?? chatSummary.name;
        subtitle = 'Has invited you to a secure chat';
      } else {
        title = hasGroupName ? chatSummary.name! : 'Unknown group';
        pictureUrl = chatSummary.groupImagePath;
        avatarName = hasGroupName ? chatSummary.name! : null;
        if (welcomerName != null) {
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

    return ListTile(
      onTap: isPending
          ? () => Routes.pushToInvite(context, chatSummary.mlsGroupId)
          : () => Routes.goToChat(context, chatSummary.mlsGroupId),
      leading: WnAnimatedAvatar(
        pictureUrl: pictureUrl,
        displayName: avatarName,
      ),
      title: Text(
        title,
        style: TextStyle(color: colors.backgroundContentPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colors.backgroundContentTertiary),
      ),
    );
  }
}
