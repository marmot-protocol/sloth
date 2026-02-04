import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_chat_avatar.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/src/rust/api/account_groups.dart' as account_groups_api;
import 'package:sloth/src/rust/api/messages.dart' as messages_api;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_chat_header.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';
import 'package:sloth/widgets/wn_slate.dart';

class ChatInviteScreen extends HookConsumerWidget {
  final String mlsGroupId;

  const ChatInviteScreen({super.key, required this.mlsGroupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = context.typographyScaled;
    final pubkey = ref.watch(accountPubkeyProvider);

    final isAccepting = useState(false);
    final isDeclining = useState(false);
    final isProcessing = isAccepting.value || isDeclining.value;

    final groupAvatarSnapshot = useChatAvatar(pubkey, mlsGroupId);

    final messagesFuture = useMemoized(
      () => messages_api.fetchAggregatedMessagesForGroup(
        pubkey: pubkey,
        groupId: mlsGroupId,
      ),
      [pubkey, mlsGroupId],
    );
    final messagesSnapshot = useFuture(messagesFuture);

    final messages = messagesSnapshot.data ?? [];
    final isLoading = messagesSnapshot.connectionState == ConnectionState.waiting;

    Future<void> handleAccept() async {
      isAccepting.value = true;
      try {
        await account_groups_api.acceptAccountGroup(
          accountPubkey: pubkey,
          mlsGroupId: mlsGroupId,
        );
        if (context.mounted) {
          Routes.goToChat(context, mlsGroupId);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.failedToAcceptInvitation(e.toString()))),
          );
        }
      } finally {
        if (context.mounted) isAccepting.value = false;
      }
    }

    Future<void> handleDecline() async {
      isDeclining.value = true;
      try {
        await account_groups_api.declineAccountGroup(
          accountPubkey: pubkey,
          mlsGroupId: mlsGroupId,
        );
        if (context.mounted) {
          Routes.goToChatList(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.failedToDeclineInvitation(e.toString()))),
          );
        }
      } finally {
        if (context.mounted) isDeclining.value = false;
      }
    }

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Column(
              children: [
                WnChatHeader(
                  mlsGroupId: mlsGroupId,
                  displayName: groupAvatarSnapshot.data?.displayName ?? '',
                  pictureUrl: groupAvatarSnapshot.data?.pictureUrl,
                  onBack: () => Routes.goToChatList(context),
                  onMenuTap: () => Routes.pushToWip(context),
                ),
                SizedBox(height: 48.h),
                WnAvatar(
                  pictureUrl: groupAvatarSnapshot.data?.pictureUrl,
                  displayName: groupAvatarSnapshot.data?.displayName,
                  size: WnAvatarSize.large,
                  color: AvatarColor.fromPubkey(mlsGroupId),
                ),
                SizedBox(height: 16.h),
                Text(
                  groupAvatarSnapshot.data?.displayName ?? '',
                  style: typography.semiBold18.copyWith(
                    color: colors.backgroundContentPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
              ],
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colors.backgroundContentPrimary,
                      ),
                    )
                  : messages.isEmpty
                  ? Center(
                      child: Text(
                        context.l10n.invitedToSecureChat,
                        style: typography.medium14.copyWith(
                          color: colors.backgroundContentTertiary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isOwnMessage = message.pubkey == pubkey;
                        return WnMessageBubble(
                          message: message,
                          isOwnMessage: isOwnMessage,
                          currentUserPubkey: pubkey,
                        );
                      },
                    ),
            ),
            WnSlate(
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 12.h,
                  children: [
                    WnButton(
                      text: context.l10n.decline,
                      type: WnButtonType.outline,
                      loading: isDeclining.value,
                      disabled: isProcessing,
                      onPressed: handleDecline,
                    ),
                    WnButton(
                      text: context.l10n.accept,
                      loading: isAccepting.value,
                      disabled: isProcessing,
                      onPressed: handleAccept,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
