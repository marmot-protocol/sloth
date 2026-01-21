import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/src/rust/api/messages.dart';

typedef ChatMessagesResult = ({
  int messageCount,
  ChatMessage Function(int reversedIndex) getMessage,
  int? Function(String messageId) getReversedMessageIndex,
  bool isLoading,
  String? latestMessageId,
  String? latestMessagePubkey,
});

ChatMessagesResult useChatMessages(String groupId) {
  final messageIds = useRef<List<String>>([]);
  final messagesById = useRef<Map<String, ChatMessage>>({});
  final indexById = useRef<Map<String, int>>({});

  final stream = useMemoized(
    () => subscribeToGroupMessages(groupId: groupId).map((item) {
      return item.when(
        initialSnapshot: (initialChatMessages) {
          messageIds.value = [];
          messagesById.value = {};
          indexById.value = {};

          for (var i = 0; i < initialChatMessages.length; i++) {
            final message = initialChatMessages[i];
            messageIds.value.add(message.id);
            messagesById.value[message.id] = message;
            indexById.value[message.id] = i;
          }

          final lastMessage = initialChatMessages.isNotEmpty ? initialChatMessages.last : null;
          return (
            messageCount: initialChatMessages.length,
            latestMessageId: lastMessage?.id,
            latestMessagePubkey: lastMessage?.pubkey,
          );
        },
        update: (update) {
          final message = update.message;

          if (update.trigger == UpdateTrigger.newMessage) {
            final newIndex = messageIds.value.length;
            messageIds.value.add(message.id);
            messagesById.value[message.id] = message;
            indexById.value[message.id] = newIndex;
          } else if (update.trigger == UpdateTrigger.messageDeleted) {
            messagesById.value[message.id] = message;
          }

          final lastId = messageIds.value.isNotEmpty ? messageIds.value.last : null;
          final lastPubkey = lastId != null ? messagesById.value[lastId]?.pubkey : null;
          return (
            messageCount: messageIds.value.length,
            latestMessageId: lastId,
            latestMessagePubkey: lastPubkey,
          );
        },
      );
    }),
    [groupId],
  );

  final initialData = (
    messageCount: 0,
    latestMessageId: null,
    latestMessagePubkey: null,
  );
  final snapshot = useStream(stream, initialData: initialData);
  final isLoading = snapshot.connectionState == ConnectionState.waiting;

  ChatMessage getMessage(int reversedIndex) {
    final length = messageIds.value.length;
    final naturalIndex = length - 1 - reversedIndex;
    final messageId = messageIds.value[naturalIndex];
    return messagesById.value[messageId]!;
  }

  int? getReversedMessageIndex(String messageId) {
    final naturalIndex = indexById.value[messageId];
    if (naturalIndex == null) return null;
    return messageIds.value.length - 1 - naturalIndex;
  }

  return (
    messageCount: snapshot.data?.messageCount ?? 0,
    getMessage: getMessage,
    getReversedMessageIndex: getReversedMessageIndex,
    isLoading: isLoading,
    latestMessageId: snapshot.data?.latestMessageId,
    latestMessagePubkey: snapshot.data?.latestMessagePubkey,
  );
}
