import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:sloth/hooks/use_chat_avatar.dart';
import 'package:sloth/hooks/use_chat_input.dart';
import 'package:sloth/hooks/use_chat_messages.dart';
import 'package:sloth/hooks/use_chat_scroll.dart';
import 'package:sloth/l10n/l10n.dart';
import 'package:sloth/providers/account_pubkey_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/message_actions_screen.dart';
import 'package:sloth/services/message_service.dart';
import 'package:sloth/src/rust/api/messages.dart' show ChatMessage;
import 'package:sloth/theme.dart';
import 'package:sloth/widgets/wn_chat_header.dart';
import 'package:sloth/widgets/wn_fade_overlay.dart';
import 'package:sloth/widgets/wn_icon.dart';
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
    final messageService = useMemoized(
      () => MessageService(pubkey: pubkey, groupId: groupId),
      [pubkey, groupId],
    );

    useChatScroll(
      scrollController: scrollController,
      focusNode: input.focusNode,
      latestMessageId: latestMessageId,
      isLatestMessageOwn: latestMessagePubkey == pubkey,
    );

    Future<void> sendMessage(String message) async {
      await messageService.sendTextMessage(content: message);
    }

    Future<void> toggleReaction(ChatMessage message, String emoji) {
      return messageService.toggleReaction(message: message, emoji: emoji);
    }

    Future<void> showMessageMenu(ChatMessage message) async {
      FocusScope.of(context).unfocus();
      await MessageActionsScreen.show(
        context,
        message: message,
        pubkey: pubkey,
        onDelete: () => messageService.deleteTextMessage(
          messageId: message.id,
          messagePubkey: message.pubkey,
        ),
        onAddReaction: (emoji) => messageService.sendReaction(
          messageId: message.id,
          messagePubkey: message.pubkey,
          messageKind: message.kind,
          emoji: emoji,
        ),
        onRemoveReaction: (reactionId) => messageService.deleteReaction(
          reactionId: reactionId,
          reactionPubkey: pubkey,
        ),
      );
      if (context.mounted) FocusManager.instance.primaryFocus?.unfocus();
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
                  onMenuTap: () {
                    final otherPubkey = groupAvatarSnapshot.data?.otherMemberPubkey;
                    if (otherPubkey != null) {
                      Routes.pushToChatInfo(context, otherPubkey);
                    } else {
                      Routes.pushToWip(context);
                    }
                  },
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
                          context.l10n.noMessagesYet,
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
                                currentUserPubkey: pubkey,
                                onLongPress: () => showMessageMenu(message),
                                onReaction: (emoji) => toggleReaction(message, emoji),
                              );
                            },
                          ),
                          WnFadeOverlay.bottom(color: colors.backgroundPrimary),
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
            SnackBar(content: Text(context.l10n.failedToSendMessage)),
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
                hintText: context.l10n.messagePlaceholder,
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
                        child: Center(
                          child: WnIcon(
                            WnIcons.arrowUp,
                            color: colors.fillContentPrimary,
                            size: 20.sp,
                          ),
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
