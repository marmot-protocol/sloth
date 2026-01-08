import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_chat_list.dart';
import 'package:sloth/src/rust/api/chat_list.dart';
import 'package:sloth/src/rust/api/groups.dart' show GroupType;
import 'package:sloth/src/rust/frb_generated.dart';
import '../test_helpers.dart';

ChatSummary _chatSummary(String id, DateTime createdAt) => ChatSummary(
  mlsGroupId: 'mls_$id',
  name: 'Chat $id',
  groupType: GroupType.group,
  createdAt: createdAt,
  pendingConfirmation: false,
);

class _MockApi implements RustLibApi {
  StreamController<ChatListStreamItem>? controller;

  void emitInitialSnapshot(List<ChatSummary> items) {
    controller?.add(ChatListStreamItem.initialSnapshot(items: items));
  }

  void emitUpdate(ChatListUpdateTrigger trigger, ChatSummary item) {
    controller?.add(
      ChatListStreamItem.update(
        update: ChatListUpdate(trigger: trigger, item: item),
      ),
    );
  }

  @override
  Stream<ChatListStreamItem> crateApiChatListSubscribeToChatList({
    required String accountPubkey,
  }) {
    controller?.close();
    controller = StreamController<ChatListStreamItem>.broadcast();
    return controller!.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _api = _MockApi();

Future<ChatListResult Function()> _pump(WidgetTester tester, String pubkey) async {
  return await mountHook(tester, () => useChatList(pubkey));
}

void main() {
  setUpAll(() => RustLib.initMock(api: _api));

  setUp(() {
    _api.controller?.close();
    _api.controller = null;
  });

  group('useChatList', () {
    testWidgets('starts with empty map', (tester) async {
      final getResult = await _pump(tester, 'pk1');

      expect(getResult().snapshot.data, isEmpty);
    });

    testWidgets('is waiting for initial data', (tester) async {
      final getResult = await _pump(tester, 'pk1');

      expect(getResult().snapshot.connectionState, ConnectionState.waiting);
    });

    testWidgets('returns chats from initial snapshot', (tester) async {
      final getResult = await _pump(tester, 'pk1');

      _api.emitInitialSnapshot([
        _chatSummary('c1', DateTime(2024)),
        _chatSummary('c2', DateTime(2024, 1, 2)),
      ]);
      await tester.pump();

      expect(getResult().snapshot.data?.length, 2);
    });

    testWidgets('preserves order from initial snapshot', (tester) async {
      final getResult = await _pump(tester, 'pk1');

      _api.emitInitialSnapshot([
        _chatSummary('c1', DateTime(2024)),
        _chatSummary('c2', DateTime(2024, 1, 2)),
      ]);
      await tester.pump();

      final keys = getResult().snapshot.data?.keys.toList();
      expect(keys?.first, 'mls_c1');
      expect(keys?.last, 'mls_c2');
    });

    testWidgets('newGroup prepends to front', (tester) async {
      final getResult = await _pump(tester, 'pk1');

      _api.emitInitialSnapshot([_chatSummary('c1', DateTime(2024))]);
      await tester.pumpAndSettle();

      _api.emitUpdate(
        ChatListUpdateTrigger.newGroup,
        _chatSummary('c2', DateTime(2024, 1, 2)),
      );
      await tester.pumpAndSettle();

      final keys = getResult().snapshot.data?.keys.toList();
      expect(keys?.length, 2);
      expect(keys?.first, 'mls_c2');
    });

    testWidgets('newLastMessage moves chat to front', (tester) async {
      final getResult = await _pump(tester, 'pk1');

      _api.emitInitialSnapshot([
        _chatSummary('c1', DateTime(2024)),
        _chatSummary('c2', DateTime(2024, 1, 2)),
      ]);
      await tester.pump();

      _api.emitUpdate(
        ChatListUpdateTrigger.newLastMessage,
        _chatSummary('c1', DateTime(2024, 1, 3)),
      );
      await tester.pump();

      final keys = getResult().snapshot.data?.keys.toList();
      expect(keys?.first, 'mls_c1');
    });

    testWidgets('lastMessageDeleted updates in place', (tester) async {
      final getResult = await _pump(tester, 'pk1');

      _api.emitInitialSnapshot([
        _chatSummary('c1', DateTime(2024)),
        _chatSummary('c2', DateTime(2024, 1, 2)),
      ]);
      await tester.pump();

      final updated = ChatSummary(
        mlsGroupId: 'mls_c1',
        name: 'Updated Chat',
        groupType: GroupType.group,
        createdAt: DateTime(2024),
        pendingConfirmation: false,
      );
      _api.emitUpdate(ChatListUpdateTrigger.lastMessageDeleted, updated);
      await tester.pump();

      final data = getResult().snapshot.data!;
      final keys = data.keys.toList();
      expect(keys.first, 'mls_c1');
      expect(data['mls_c1']?.name, 'Updated Chat');
    });
  });
}
