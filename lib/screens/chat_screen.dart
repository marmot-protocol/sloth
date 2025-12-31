import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/extensions/build_context.dart';
import 'package:sloth/hooks/use_chat_avatar.dart';
import 'package:sloth/hooks/use_chat_messages.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/widgets/wn_chat_header.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

class ChatScreen extends HookConsumerWidget {
  final String groupId;

  const ChatScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final messagesResult = useChatMessages(groupId);
    final groupAvatarSnapshot = useChatAvatar(pubkey, groupId);

    final messages = messagesResult.snapshot.data ?? [];
    final isLoading = messagesResult.snapshot.connectionState == ConnectionState.waiting;

    return Scaffold(
      backgroundColor: colors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            WnSlateContainer(
              child: WnChatHeader(
                displayName: groupAvatarSnapshot.data?.displayName ?? '',
                pictureUrl: groupAvatarSnapshot.data?.pictureUrl,
                onBack: () => Routes.goToChatList(context),
                onMenuTap: () => Routes.pushToWip(context),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: colors.foregroundPrimary,
                      ),
                    )
                  : messages.isEmpty
                  ? Center(
                      child: Text(
                        'No messages yet',
                        style: TextStyle(
                          color: colors.foregroundTertiary,
                          fontSize: 14.sp,
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
                        );
                      },
                    ),
            ),
            const _ChatInput(),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      color: colors.backgroundPrimary,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: colors.backgroundTertiary,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: colors.foregroundTertiary.withValues(alpha: 0.5),
          ),
        ),
        child: Text(
          'Message',
          style: TextStyle(
            color: colors.foregroundTertiary,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
