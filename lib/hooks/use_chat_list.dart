import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/src/rust/api/chat_list.dart';

typedef ChatListMap = Map<String, ChatSummary>;
typedef ChatListResult = ({AsyncSnapshot<ChatListMap> snapshot});

ChatListResult useChatList(String pubkey) {
  final chatMap = useRef(<String, ChatSummary>{});

  final stream = useMemoized(
    () => subscribeToChatList(accountPubkey: pubkey).map((item) {
      return item.when(
        initialSnapshot: (items) {
          chatMap.value = {for (final c in items.reversed) c.mlsGroupId: c};
          return chatMap.value;
        },
        update: (update) {
          final id = update.item.mlsGroupId;
          switch (update.trigger) {
            case ChatListUpdateTrigger.lastMessageDeleted:
              chatMap.value[id] = update.item;
            case ChatListUpdateTrigger.newGroup:
              chatMap.value[id] = update.item;
            case ChatListUpdateTrigger.newLastMessage:
              chatMap.value.remove(id);
              chatMap.value[id] = update.item;
          }
          return chatMap.value;
        },
      );
    }),
    [pubkey],
  );

  final snapshot = useStream(stream, initialData: <String, ChatSummary>{});
  return (snapshot: snapshot);
}
