import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_chat_messages.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import '../test_helpers.dart';

ChatMessage _message(String id, DateTime createdAt, {String content = 'test'}) => ChatMessage(
  id: id,
  pubkey: 'pubkey',
  content: content,
  createdAt: createdAt,
  tags: const [],
  isReply: false,
  isDeleted: false,
  contentTokens: const [],
  reactions: const ReactionSummary(byEmoji: [], userReactions: []),
  mediaAttachments: const [],
  kind: 9,
);

class _MockApi implements RustLibApi {
  StreamController<MessageStreamItem>? controller;

  void emitInitialSnapshot(List<ChatMessage> messages) {
    controller?.add(MessageStreamItem.initialSnapshot(messages: messages));
  }

  void emitNewMessage(ChatMessage message) {
    controller?.add(
      MessageStreamItem.update(
        update: MessageUpdate(trigger: UpdateTrigger.newMessage, message: message),
      ),
    );
  }

  @override
  Stream<MessageStreamItem> crateApiMessagesSubscribeToGroupMessages({
    required String groupId,
  }) {
    controller?.close();
    controller = StreamController<MessageStreamItem>.broadcast();
    return controller!.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _api = _MockApi();

Future<ChatMessagesResult Function()> _pump(WidgetTester tester, String groupId) async {
  return await mountHook(tester, () => useChatMessages(groupId));
}

void main() {
  setUpAll(() => RustLib.initMock(api: _api));

  setUp(() {
    _api.controller?.close();
    _api.controller = null;
  });

  group('useChatMessages', () {
    testWidgets('starts with empty list', (tester) async {
      final getResult = await _pump(tester, 'group1');

      expect(getResult().snapshot.data, isEmpty);
    });

    testWidgets('is waiting for initial data', (tester) async {
      final getResult = await _pump(tester, 'group1');

      expect(
        getResult().snapshot.connectionState,
        ConnectionState.waiting,
      );
    });

    testWidgets('returns messages from initial snapshot', (tester) async {
      final getResult = await _pump(tester, 'group1');

      _api.emitInitialSnapshot([
        _message('m1', DateTime(2024)),
        _message('m2', DateTime(2024, 1, 2)),
      ]);
      await tester.pump();

      expect(getResult().snapshot.data?.length, 2);
    });

    testWidgets('preserves order of events', (tester) async {
      final getResult = await _pump(tester, 'group1');

      _api.emitInitialSnapshot([
        _message('m1', DateTime(2024)),
        _message('m2', DateTime(2024, 1, 2)),
      ]);
      await tester.pump();

      final messages = getResult().snapshot.data!;
      expect(messages.first.id, 'm1');
      expect(messages.last.id, 'm2');
    });

    testWidgets('appends new message at end', (tester) async {
      final getResult = await _pump(tester, 'group1');

      _api.emitInitialSnapshot([
        _message('m1', DateTime(2024)),
      ]);
      await tester.pumpAndSettle();

      _api.emitNewMessage(_message('m2', DateTime(2024, 1, 2)));
      await tester.pumpAndSettle();

      final messages = getResult().snapshot.data!;
      expect(messages.length, 2);
      expect(messages.last.id, 'm2');
    });
  });
}
