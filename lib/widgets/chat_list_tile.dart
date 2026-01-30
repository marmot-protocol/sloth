import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/locale_provider.dart';
import 'package:sloth/routes.dart' show Routes;
import 'package:sloth/services/user_service.dart';
import 'package:sloth/src/rust/api/chat_list.dart' show ChatSummary;
import 'package:sloth/src/rust/api/groups.dart' show GroupType;
import 'package:sloth/theme.dart';
import 'package:sloth/utils/metadata.dart';
import 'package:sloth/widgets/wn_avatar.dart';

class ChatListTile extends HookConsumerWidget {
  final ChatSummary chatSummary;

  const ChatListTile({
    super.key,
    required this.chatSummary,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatters = ref.watch(localeFormattersProvider);
    final colors = context.colors;
    final isDm = chatSummary.groupType == GroupType.directMessage;
    final isPending = chatSummary.pendingConfirmation;
    final hasWelcomer = chatSummary.welcomerPubkey != null;

    final welcomerMetadata = useMemoized(
      () async {
        if (!isPending || !hasWelcomer) return null;

        try {
          return UserService(chatSummary.welcomerPubkey!).fetchMetadata();
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
        title = welcomerName ?? chatSummary.name ?? context.l10n.unknownUser;
        pictureUrl = welcomerSnapshot.data?.picture ?? chatSummary.groupImageUrl;
        avatarName = welcomerName ?? chatSummary.name;
        subtitle = context.l10n.hasInvitedYouToSecureChat;
      } else {
        title = hasGroupName ? chatSummary.name! : context.l10n.unknownGroup;
        pictureUrl = chatSummary.groupImagePath;
        avatarName = hasGroupName ? chatSummary.name! : null;
        if (welcomerName != null) {
          subtitle = context.l10n.userInvitedYouToSecureChat(welcomerName);
        } else {
          subtitle = context.l10n.youHaveBeenInvitedToSecureChat;
        }
      }
    } else {
      if (isDm) {
        title = hasGroupName ? chatSummary.name! : context.l10n.unknownUser;
        pictureUrl = chatSummary.groupImageUrl;
      } else {
        title = hasGroupName ? chatSummary.name! : context.l10n.unknownGroup;
        pictureUrl = chatSummary.groupImagePath;
      }
      avatarName = hasGroupName ? chatSummary.name! : null;
      subtitle = chatSummary.lastMessage?.content ?? '';
    }

    final timestamp = chatSummary.lastMessage?.createdAt ?? chatSummary.createdAt;
    final formattedTime = formatters.formatRelativeTime(timestamp, context.l10n);

    return ListTile(
      onTap: isPending
          ? () => Routes.pushToInvite(context, chatSummary.mlsGroupId)
          : () => Routes.goToChat(context, chatSummary.mlsGroupId),
      leading: WnAvatar(
        pictureUrl: pictureUrl,
        displayName: avatarName,
        color: AvatarColor.fromPubkey(chatSummary.mlsGroupId),
      ),
      title: Text(
        title,
        style: TextStyle(color: colors.backgroundContentPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colors.backgroundContentSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        formattedTime,
        style: TextStyle(
          color: colors.backgroundContentTertiary,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
