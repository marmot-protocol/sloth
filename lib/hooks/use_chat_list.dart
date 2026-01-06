import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/src/rust/api/chat_list.dart' as chat_list_api;

typedef ChatListResult = ({
  AsyncSnapshot<List<chat_list_api.ChatSummary>> snapshot,
  VoidCallback refresh,
});

ChatListResult useChatList(String pubkey) {
  final refreshKey = useState(0);
  final future = useMemoized(
    () async {
      final chatSummaries = await chat_list_api.getChatList(accountPubkey: pubkey);
      return chatSummaries.toList();
    },
    [pubkey, refreshKey.value],
  );
  final snapshot = useFuture(future);

  return (
    snapshot: snapshot,
    refresh: () => refreshKey.value++,
  );
}
