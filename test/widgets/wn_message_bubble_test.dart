import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';
import '../test_helpers.dart';

ChatMessage _message({String content = 'Hello world', bool isDeleted = false}) => ChatMessage(
  id: 'msg1',
  pubkey: 'pubkey',
  content: content,
  createdAt: DateTime(2024),
  tags: const [],
  isReply: false,
  isDeleted: isDeleted,
  contentTokens: const [],
  reactions: const ReactionSummary(byEmoji: [], userReactions: []),
  mediaAttachments: const [],
  kind: 9,
);

void main() {
  group('WnMessageBubble', () {
    testWidgets('displays message content', (tester) async {
      await mountWidget(
        WnMessageBubble(message: _message(content: 'Test message'), isOwnMessage: false),
        tester,
      );

      expect(find.text('Test message'), findsOneWidget);
    });

    group('own message', () {
      testWidgets('aligns to the right', (tester) async {
        await mountWidget(
          WnMessageBubble(message: _message(), isOwnMessage: true),
          tester,
        );

        final align = tester.widget<Align>(find.byType(Align));
        expect(align.alignment, Alignment.centerRight);
      });
    });

    group('other user message', () {
      testWidgets('aligns to the left', (tester) async {
        await mountWidget(
          WnMessageBubble(message: _message(), isOwnMessage: false),
          tester,
        );

        final align = tester.widget<Align>(find.byType(Align));
        expect(align.alignment, Alignment.centerLeft);
      });
    });

    group('deleted message', () {
      testWidgets('renders nothing', (tester) async {
        await mountWidget(
          WnMessageBubble(message: _message(isDeleted: true), isOwnMessage: false),
          tester,
        );

        expect(find.byType(SizedBox), findsOneWidget);
      });
    });

    group('onLongPress', () {
      testWidgets('calls callback when long pressed', (tester) async {
        var called = false;
        await mountWidget(
          WnMessageBubble(
            message: _message(),
            isOwnMessage: false,
            onLongPress: () => called = true,
          ),
          tester,
        );

        await tester.longPress(find.byType(GestureDetector));

        expect(called, isTrue);
      });
    });
  });
}
