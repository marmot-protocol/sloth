import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/hooks/use_chat_input.dart';
import 'package:whitenoise/src/rust/api/messages.dart';
import '../test_helpers.dart';

ChatMessage _createTestMessage({String id = 'msg-1', String content = 'Test message'}) {
  return ChatMessage(
    id: id,
    pubkey: testPubkeyA,
    content: content,
    createdAt: DateTime.now(),
    tags: const [],
    isReply: false,
    isDeleted: false,
    contentTokens: const [],
    reactions: const ReactionSummary(byEmoji: [], userReactions: []),
    mediaAttachments: const [],
    kind: 9,
  );
}

void main() {
  group('useChatInput', () {
    testWidgets('provides a controller', (tester) async {
      final result = (await mountHook(tester, useChatInput))();

      expect(result.controller, isNotNull);
    });

    testWidgets('provides a focusNode', (tester) async {
      final result = (await mountHook(tester, useChatInput))();

      expect(result.focusNode, isNotNull);
    });

    testWidgets('hasFocus is false initially', (tester) async {
      final result = (await mountHook(tester, useChatInput))();

      expect(result.hasFocus, isFalse);
    });

    testWidgets('hasFocus is true when focus is requested', (tester) async {
      final getResult = await mountHook(tester, useChatInput);
      getResult().focusNode.requestFocus();
      await tester.pump();

      expect(getResult().hasFocus, isTrue);
    });

    testWidgets('hasContent is false initially', (tester) async {
      final result = (await mountHook(tester, useChatInput))();

      expect(result.hasContent, isFalse);
    });

    testWidgets('hasContent is true when text is entered', (tester) async {
      final getResult = await mountHook(tester, useChatInput);
      getResult().controller.text = 'hello';
      await tester.pump();

      expect(getResult().hasContent, isTrue);
    });

    testWidgets('clear empties the controller', (tester) async {
      final getResult = await mountHook(tester, useChatInput);
      getResult().controller.text = 'hello';
      await tester.pump();
      expect(getResult().hasContent, isTrue);

      getResult().clear();
      await tester.pump();

      expect(getResult().controller.text, isEmpty);
      expect(getResult().hasContent, isFalse);
    });

    group('reply state', () {
      testWidgets('replyingTo is null initially', (tester) async {
        final result = (await mountHook(tester, useChatInput))();

        expect(result.replyingTo, isNull);
      });

      testWidgets('setReplyingTo sets the message to reply to', (tester) async {
        final getResult = await mountHook(tester, useChatInput);
        final message = _createTestMessage();

        getResult().setReplyingTo(message);
        await tester.pump();

        expect(getResult().replyingTo, equals(message));
      });

      testWidgets('cancelReply clears the reply state', (tester) async {
        final getResult = await mountHook(tester, useChatInput);
        final message = _createTestMessage();

        getResult().setReplyingTo(message);
        await tester.pump();
        expect(getResult().replyingTo, isNotNull);

        getResult().cancelReply();
        await tester.pump();

        expect(getResult().replyingTo, isNull);
      });

      testWidgets('clear also clears the reply state', (tester) async {
        final getResult = await mountHook(tester, useChatInput);
        final message = _createTestMessage();

        getResult().setReplyingTo(message);
        getResult().controller.text = 'hello';
        await tester.pump();
        expect(getResult().replyingTo, isNotNull);
        expect(getResult().hasContent, isTrue);

        getResult().clear();
        await tester.pump();

        expect(getResult().replyingTo, isNull);
        expect(getResult().controller.text, isEmpty);
      });
    });
  });
}
