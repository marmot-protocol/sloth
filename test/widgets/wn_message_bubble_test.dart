import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';
import '../test_helpers.dart';

ChatMessage _message({String content = 'Hello world'}) => ChatMessage(
  id: 'msg1',
  pubkey: 'pubkey',
  content: content,
  createdAt: DateTime(2024),
  tags: const [],
  isReply: false,
  isDeleted: false,
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
  });
}
