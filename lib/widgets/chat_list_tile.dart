import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/src/rust/api/groups.dart' show ChatSummary, GroupType;
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

    final hasGroupName = chatSummary.name?.isNotEmpty ?? false;

    final String? pictureUrl;
    final String title;
    final String subtitle;
    final bool isDm = chatSummary.groupType == GroupType.directMessage;
    final String defaultTitle = isDm ? 'Unknown user' : 'Unknown group';

    title = hasGroupName ? chatSummary.name! : defaultTitle;
    pictureUrl = isDm ? chatSummary.groupImageUrl : chatSummary.groupImagePath;
    subtitle = chatSummary.pendingConfirmation
        ? 'You have been invited to a secure chat'
        : chatSummary.lastMessage?.content ?? '';

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: ListTile(
        onTap: chatSummary.pendingConfirmation
            ? () => Routes.pushToInvite(context, chatSummary.mlsGroupId)
            : () => Routes.goToChat(context, chatSummary.mlsGroupId),
        leading: WnAnimatedAvatar(
          pictureUrl: pictureUrl,
          displayName: chatSummary.name,
        ),
        title: Text(
          title,
          style: TextStyle(color: colors.foregroundPrimary),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: colors.foregroundTertiary),
        ),
      ),
    );
  }
}
