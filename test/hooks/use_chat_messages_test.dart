import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_chat_messages.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import '../test_helpers.dart';

ChatMessage _message(
  String id,
  DateTime createdAt, {
  String content = 'test',
  String pubkey = 'pubkey',
}) => ChatMessage(
  id: id,
  pubkey: pubkey,
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

      expect(getResult().messageCount, 0);
    });

    testWidgets('is loading before initial data', (tester) async {
      final getResult = await _pump(tester, 'group1');

      expect(getResult().isLoading, isTrue);
    });

    testWidgets('is not loading after initial data arrives', (tester) async {
      final getResult = await _pump(tester, 'group1');

      _api.emitInitialSnapshot([_message('m1', DateTime(2024))]);
      await tester.pumpAndSettle();

      expect(getResult().isLoading, isFalse);
    });

    testWidgets('returns messages from initial snapshot', (tester) async {
      final getResult = await _pump(tester, 'group1');

      _api.emitInitialSnapshot([
        _message('m1', DateTime(2024)),
        _message('m2', DateTime(2024, 1, 2)),
      ]);
      await tester.pump();

      expect(getResult().messageCount, 2);
    });

    testWidgets('returns messages in reversed order (newest first)', (tester) async {
      final getResult = await _pump(tester, 'group1');

      _api.emitInitialSnapshot([
        _message('m1', DateTime(2024)),
        _message('m2', DateTime(2024, 1, 2)),
      ]);
      await tester.pump();

      final result = getResult();
      expect(result.getMessage(0).id, 'm2');
      expect(result.getMessage(1).id, 'm1');
    });

    testWidgets('prepends new message at start (newest first)', (tester) async {
      final getResult = await _pump(tester, 'group1');

      _api.emitInitialSnapshot([
        _message('m1', DateTime(2024)),
      ]);
      await tester.pumpAndSettle();

      _api.emitNewMessage(_message('m2', DateTime(2024, 1, 2)));
      await tester.pumpAndSettle();

      final result = getResult();
      expect(result.messageCount, 2);
      expect(result.getMessage(0).id, 'm2');
    });

    group('getReversedMessageIndex', () {
      testWidgets('returns correct index for messages', (tester) async {
        final getResult = await _pump(tester, 'group1');

        _api.emitInitialSnapshot([
          _message('m1', DateTime(2024)),
          _message('m2', DateTime(2024, 1, 2)),
        ]);
        await tester.pump();

        final result = getResult();
        expect(result.getReversedMessageIndex('m2'), 0);
        expect(result.getReversedMessageIndex('m1'), 1);
      });

      testWidgets('returns null for unknown message id', (tester) async {
        final getResult = await _pump(tester, 'group1');

        _api.emitInitialSnapshot([
          _message('m1', DateTime(2024)),
        ]);
        await tester.pump();

        expect(getResult().getReversedMessageIndex('unknown'), isNull);
      });
    });

    group('latestMessageId', () {
      group('before initial load', () {
        testWidgets('is null', (tester) async {
          final getResult = await _pump(tester, 'group1');

          expect(getResult().latestMessageId, isNull);
        });
      });

      group('when initial load has messages', () {
        testWidgets('is last message id', (tester) async {
          final getResult = await _pump(tester, 'group1');

          _api.emitInitialSnapshot([
            _message('m1', DateTime(2024)),
            _message('m2', DateTime(2024, 1, 2)),
          ]);
          await tester.pumpAndSettle();

          expect(getResult().latestMessageId, 'm2');
        });
      });

      group('when initial load is empty', () {
        testWidgets('is null', (tester) async {
          final getResult = await _pump(tester, 'group1');

          _api.emitInitialSnapshot([]);
          await tester.pumpAndSettle();

          expect(getResult().latestMessageId, isNull);
        });
      });

      group('when new message arrives', () {
        testWidgets('updates to new message id', (tester) async {
          final getResult = await _pump(tester, 'group1');

          _api.emitInitialSnapshot([]);
          await tester.pumpAndSettle();

          expect(getResult().latestMessageId, isNull);

          _api.emitNewMessage(_message('m1', DateTime(2024)));
          await tester.pumpAndSettle();

          expect(getResult().latestMessageId, 'm1');

          _api.emitNewMessage(_message('m2', DateTime(2024, 1, 2)));
          await tester.pumpAndSettle();

          expect(getResult().latestMessageId, 'm2');
        });
      });
    });

    group('latestMessagePubkey', () {
      group('before initial load', () {
        testWidgets('is null', (tester) async {
          final getResult = await _pump(tester, 'group1');

          expect(getResult().latestMessagePubkey, isNull);
        });
      });

      group('when initial load has messages', () {
        testWidgets('is last message pubkey', (tester) async {
          final getResult = await _pump(tester, 'group1');

          _api.emitInitialSnapshot([
            _message('m1', DateTime(2024), pubkey: 'alice'),
            _message('m2', DateTime(2024, 1, 2), pubkey: 'bob'),
          ]);
          await tester.pumpAndSettle();

          expect(getResult().latestMessagePubkey, 'bob');
        });
      });

      group('when initial load is empty', () {
        testWidgets('is null', (tester) async {
          final getResult = await _pump(tester, 'group1');

          _api.emitInitialSnapshot([]);
          await tester.pumpAndSettle();

          expect(getResult().latestMessagePubkey, isNull);
        });
      });

      group('when new message arrives', () {
        testWidgets('updates to new message pubkey', (tester) async {
          final getResult = await _pump(tester, 'group1');

          _api.emitInitialSnapshot([]);
          await tester.pumpAndSettle();

          expect(getResult().latestMessagePubkey, isNull);

          _api.emitNewMessage(_message('m1', DateTime(2024), pubkey: 'alice'));
          await tester.pumpAndSettle();

          expect(getResult().latestMessagePubkey, 'alice');

          _api.emitNewMessage(_message('m2', DateTime(2024, 1, 2), pubkey: 'bob'));
          await tester.pumpAndSettle();

          expect(getResult().latestMessagePubkey, 'bob');
        });
      });
    });
  });
}
