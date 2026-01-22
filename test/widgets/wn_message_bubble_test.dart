import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';
import 'package:sloth/widgets/wn_message_reactions.dart';
import '../test_helpers.dart';

ChatMessage _message({
  String content = 'Hello world',
  bool isDeleted = false,
  ReactionSummary reactions = const ReactionSummary(byEmoji: [], userReactions: []),
}) => ChatMessage(
  id: 'msg1',
  pubkey: 'pubkey',
  content: content,
  createdAt: DateTime(2024),
  tags: const [],
  isReply: false,
  isDeleted: isDeleted,
  contentTokens: const [],
  reactions: reactions,
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

    group('reactions', () {
      testWidgets('does not show reactions when empty', (tester) async {
        await mountWidget(
          WnMessageBubble(message: _message(), isOwnMessage: false),
          tester,
        );

        expect(find.byType(WnMessageReactions), findsNothing);
      });

      testWidgets('shows reactions when present', (tester) async {
        final reactions = ReactionSummary(
          byEmoji: [
            EmojiReaction(emoji: '👍', count: BigInt.from(2), users: const ['u1', 'u2']),
          ],
          userReactions: const [],
        );
        await mountWidget(
          WnMessageBubble(message: _message(reactions: reactions), isOwnMessage: false),
          tester,
        );

        expect(find.byType(WnMessageReactions), findsOneWidget);
        expect(find.text('👍'), findsOneWidget);
      });

      testWidgets('passes currentUserPubkey to reactions', (tester) async {
        final reactions = ReactionSummary(
          byEmoji: [
            EmojiReaction(emoji: '👍', count: BigInt.one, users: const ['currentUser']),
          ],
          userReactions: const [],
        );
        await mountWidget(
          WnMessageBubble(
            message: _message(reactions: reactions),
            isOwnMessage: false,
            currentUserPubkey: 'currentUser',
          ),
          tester,
        );

        final reactionBubbles = tester.widget<WnMessageReactions>(find.byType(WnMessageReactions));
        expect(reactionBubbles.currentUserPubkey, 'currentUser');
      });

      testWidgets('passes onReaction to reactions', (tester) async {
        final reactions = ReactionSummary(
          byEmoji: [
            EmojiReaction(emoji: '👍', count: BigInt.one, users: const ['other']),
          ],
          userReactions: const [],
        );
        String? tappedEmoji;
        await mountWidget(
          WnMessageBubble(
            message: _message(reactions: reactions),
            isOwnMessage: false,
            currentUserPubkey: 'currentUser',
            onReaction: (emoji) => tappedEmoji = emoji,
          ),
          tester,
        );

        await tester.tap(find.text('👍'));
        await tester.pump();

        expect(tappedEmoji, '👍');
      });
    });
  });
}
