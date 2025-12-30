import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/src/rust/api/messages.dart';

typedef ChatMessagesResult = ({AsyncSnapshot<List<ChatMessage>> snapshot});

ChatMessagesResult useChatMessages(String groupId) {
  final messages = useRef(<ChatMessage>[]);

  final stream = useMemoized(
    () => subscribeToGroupMessages(groupId: groupId).map((item) {
      return item.when(
        initialSnapshot: (initial) {
          messages.value = List.of(initial);
          return messages.value;
        },
        update: (update) {
          if (update.trigger == UpdateTrigger.newMessage) {
            messages.value = [...messages.value, update.message];
          }
          return messages.value;
        },
      );
    }),
    [groupId],
  );

  final snapshot = useStream(stream, initialData: <ChatMessage>[]);
  return (snapshot: snapshot);
}
