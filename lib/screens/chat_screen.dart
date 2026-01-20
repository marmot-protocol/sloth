import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sloth/hooks/use_chat_avatar.dart';
import 'package:sloth/hooks/use_chat_input.dart';
import 'package:sloth/hooks/use_chat_messages.dart';
import 'package:sloth/hooks/use_chat_scroll.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/services/message_service.dart';
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_chat_header.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

final _logger = Logger('ChatScreen');

class ChatScreen extends HookConsumerWidget {
  final String groupId;

  const ChatScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final pubkey = ref.watch(accountPubkeyProvider);
    final (
      :messageCount,
      :getMessage,
      :getReversedMessageIndex,
      :isLoading,
      :latestMessageId,
      :latestMessagePubkey,
    ) = useChatMessages(
      groupId,
    );
    final groupAvatarSnapshot = useChatAvatar(pubkey, groupId);
    final scrollController = useScrollController();
    final input = useChatInput();
    final messageService = useMemoized(() => MessageService(pubkey), [pubkey]);

    useChatScroll(
      scrollController: scrollController,
      focusNode: input.focusNode,
      latestMessageId: latestMessageId,
      isLatestMessageOwn: latestMessagePubkey == pubkey,
    );

    Future<void> sendMessage(String message) async {
      await messageService.sendTextMessage(groupId: groupId, content: message);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                          color: colors.backgroundContentPrimary,
                        ),
                      )
                    : messageCount == 0
                    ? Center(
                        child: Text(
                          'No messages yet',
                          style: TextStyle(
                            color: colors.backgroundContentTertiary,
                            fontSize: 14.sp,
                          ),
                        ),
                      )
                    : Stack(
                        children: [
                          ListView.builder(
                            controller: scrollController,
                            reverse: true,
                            padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                            itemCount: messageCount,
                            findChildIndexCallback: (key) {
                              if (key is ValueKey<String>) {
                                return getReversedMessageIndex(key.value);
                              }
                              return null;
                            },
                            itemBuilder: (context, index) {
                              final message = getMessage(index);
                              final isOwnMessage = message.pubkey == pubkey;
                              return WnMessageBubble(
                                key: ValueKey(message.id),
                                message: message,
                                isOwnMessage: isOwnMessage,
                              );
                            },
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 20.h,
                            child: IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      colors.backgroundPrimary.withValues(alpha: 0),
                                      colors.backgroundPrimary,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              _ChatInput(input: input, onSend: sendMessage),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatInput extends StatelessWidget {
  const _ChatInput({required this.input, required this.onSend});

  final ChatInputState input;
  final Future<void> Function(String message) onSend;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Future<void> handleSend() async {
      final text = input.controller.text.trim();
      if (text.isEmpty) return;
      try {
        await onSend(text);
        input.clear();
      } catch (e, st) {
        _logger.severe('Failed to send message', e, st);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to send message. Please try again.')),
          );
        }
      }
    }

    return Container(
      padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 2.h, bottom: 24.h),
      color: colors.backgroundPrimary,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: input.controller,
              focusNode: input.focusNode,
              maxLines: 5,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.backgroundContentPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: TextStyle(color: colors.backgroundContentTertiary),
                filled: true,
                fillColor: colors.backgroundTertiary,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 20.h,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                    color: colors.borderTertiary,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: colors.borderPrimary),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: input.hasContent
                ? Padding(
                    padding: EdgeInsets.only(left: 8.w),
                    child: GestureDetector(
                      key: const Key('send_button'),
                      onTap: handleSend,
                      child: Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: colors.fillPrimary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.arrow_upward,
                          color: colors.fillContentPrimary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
