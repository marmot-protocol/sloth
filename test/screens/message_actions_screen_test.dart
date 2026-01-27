import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/l10n/generated/app_localizations.dart';
import 'package:sloth/screens/message_actions_screen.dart';
import 'package:sloth/src/rust/api/messages.dart';
import '../test_helpers.dart';

ChatMessage _createTestMessage({
  String id = 'msg-1',
  String pubkey = 'user-pubkey',
  String content = 'Test message content',
  ReactionSummary? reactions,
}) {
  return ChatMessage(
    id: id,
    pubkey: pubkey,
    content: content,
    createdAt: DateTime.now(),
    tags: const [],
    isReply: false,
    isDeleted: false,
    contentTokens: const [],
    reactions: reactions ?? const ReactionSummary(byEmoji: [], userReactions: []),
    mediaAttachments: const [],
    kind: 9,
  );
}

void main() {
  group('MessageActionsModal', () {
    testWidgets('displays message content', (tester) async {
      await mountWidget(
        MessageActionsModal(
          message: _createTestMessage(content: 'Test message'),
          isOwnMessage: false,
          onClose: () {},
          onReaction: (_) {},
          onEmojiPicker: () {},
          currentUserPubkey: 'test-pubkey',
        ),
        tester,
      );

      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('displays header', (tester) async {
      await mountWidget(
        MessageActionsModal(
          message: _createTestMessage(),
          isOwnMessage: false,
          onClose: () {},
          onReaction: (_) {},
          onEmojiPicker: () {},
          currentUserPubkey: 'test-pubkey',
        ),
        tester,
      );

      expect(find.text('Message actions'), findsOneWidget);
    });

    group('Reply button', () {
      testWidgets('is visible', (tester) async {
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        expect(find.byKey(const Key('reply_button')), findsOneWidget);
      });

      testWidgets('calls onClose when tapped', (tester) async {
        var closeCalled = false;
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () => closeCalled = true,
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('reply_button')));
        await tester.pumpAndSettle();

        expect(closeCalled, isTrue);
      });
    });

    group('Delete button', () {
      testWidgets('is visible when onDelete is provided', (tester) async {
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: true,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
            onDelete: () {},
          ),
          tester,
        );

        expect(find.byKey(const Key('delete_button')), findsOneWidget);
      });

      testWidgets('is hidden when onDelete is null', (tester) async {
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        expect(find.byKey(const Key('delete_button')), findsNothing);
      });

      testWidgets('calls onDelete when tapped', (tester) async {
        var deleteCalled = false;
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: true,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
            onDelete: () => deleteCalled = true,
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('delete_button')));
        await tester.pumpAndSettle();

        expect(deleteCalled, isTrue);
      });
    });

    group('close button', () {
      testWidgets('calls onClose when tapped', (tester) async {
        var closeCalled = false;
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () => closeCalled = true,
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('close_button')));
        await tester.pumpAndSettle();

        expect(closeCalled, isTrue);
      });
    });

    group('reactions', () {
      testWidgets('displays all reaction buttons', (tester) async {
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        for (final emoji in MessageActionsModal.reactions) {
          expect(find.text(emoji), findsOneWidget);
        }
      });

      testWidgets('displays emoji picker button', (tester) async {
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        expect(find.byKey(const Key('emoji_picker_button')), findsOneWidget);
      });

      testWidgets('reaction button calls onReaction with correct emoji when provided', (
        tester,
      ) async {
        String? receivedEmoji;
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
            onReaction: (emoji) => receivedEmoji = emoji,
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        await tester.tap(find.text('🚀'));
        await tester.pumpAndSettle();

        expect(receivedEmoji, '🚀');
      });

      testWidgets('selected emoji shows filled background', (tester) async {
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
            selectedEmojis: const {'❤', '🚀'},
          ),
          tester,
        );

        final heartButton = find.byKey(const Key('reaction_❤'));
        final heartContainer = tester.widget<Container>(
          find.descendant(of: heartButton, matching: find.byType(Container)),
        );
        expect(heartContainer.decoration, isNotNull);

        final thumbsUpButton = find.byKey(const Key('reaction_👍'));
        final thumbsUpContainer = tester.widget<Container>(
          find.descendant(of: thumbsUpButton, matching: find.byType(Container)),
        );
        expect(thumbsUpContainer.decoration, isNull);
      });

      testWidgets('emoji picker button calls onEmojiPicker when tapped', (tester) async {
        var emojiPickerCalled = false;
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () => emojiPickerCalled = true,
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('emoji_picker_button')));
        await tester.pumpAndSettle();

        expect(emojiPickerCalled, isTrue);
      });
    });

    group('own message', () {
      testWidgets('aligns message preview to the right', (tester) async {
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: true,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        final align = tester.widget<Align>(find.byType(Align).first);
        expect(align.alignment, Alignment.centerRight);
      });
    });

    group('other user message', () {
      testWidgets('aligns message preview to the left', (tester) async {
        await mountWidget(
          MessageActionsModal(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
            onReaction: (_) {},
            onEmojiPicker: () {},
            currentUserPubkey: 'test-pubkey',
          ),
          tester,
        );

        final align = tester.widget<Align>(find.byType(Align).first);
        expect(align.alignment, Alignment.centerLeft);
      });
    });
  });

  group('MessageActionsScreen.show()', () {
    Future<void> mountShowTest(
      WidgetTester tester, {
      required Widget Function(BuildContext context) builder,
    }) async {
      setUpTestView(tester);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: testDesignSize,
          builder: (_, _) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: Builder(builder: (context) => builder(context))),
          ),
        ),
      );
    }

    testWidgets('opens a route with the message menu', (tester) async {
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(),
            pubkey: 'user-pubkey',
            onReaction: (_) async {},
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Message actions'), findsOneWidget);
      expect(find.text('Test message content'), findsOneWidget);
    });

    testWidgets('shows delete button for own message', (tester) async {
      const myPubkey = 'my-pubkey';
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(pubkey: myPubkey),
            pubkey: myPubkey,
            onReaction: (_) async {},
            onDelete: () async {},
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('delete_button')), findsOneWidget);
    });

    testWidgets('hides delete button for other user message', (tester) async {
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(pubkey: 'other-user'),
            pubkey: 'my-pubkey',
            onReaction: (_) async {},
            onDelete: () async {},
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('delete_button')), findsNothing);
    });

    testWidgets('hides delete button for own message when onDelete is null', (tester) async {
      const myPubkey = 'my-pubkey';
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(pubkey: myPubkey),
            pubkey: myPubkey,
            onReaction: (_) async {},
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('delete_button')), findsNothing);
    });

    testWidgets('close button dismisses the menu', (tester) async {
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(),
            pubkey: 'user-pubkey',
            onReaction: (_) async {},
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Message actions'), findsOneWidget);

      await tester.tap(find.byKey(const Key('close_button')));
      await tester.pumpAndSettle();

      expect(find.text('Message actions'), findsNothing);
    });

    testWidgets('tapping outside dismisses the menu', (tester) async {
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(),
            pubkey: 'user-pubkey',
            onReaction: (_) async {},
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Message actions'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Message actions'), findsNothing);
    });

    testWidgets('calls onDelete and closes menu when delete button is tapped', (tester) async {
      var deleteCalled = false;
      const myPubkey = 'my-pubkey';

      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(pubkey: myPubkey),
            pubkey: myPubkey,
            onReaction: (_) async {},
            onDelete: () async {
              deleteCalled = true;
            },
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Message actions'), findsOneWidget);

      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
      expect(find.text('Message actions'), findsNothing);
    });

    testWidgets('aligns message preview right for own message', (tester) async {
      const myPubkey = 'my-pubkey';
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(pubkey: myPubkey),
            pubkey: myPubkey,
            onReaction: (_) async {},
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      final alignFinder = find.descendant(
        of: find.byType(MessageActionsModal),
        matching: find.byType(Align),
      );
      final align = tester.widget<Align>(alignFinder.first);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('aligns message preview left for other user message', (tester) async {
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(pubkey: 'other-user'),
            pubkey: 'my-pubkey',
            onReaction: (_) async {},
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      final alignFinder = find.descendant(
        of: find.byType(MessageActionsModal),
        matching: find.byType(Align),
      );
      final align = tester.widget<Align>(alignFinder.first);
      expect(align.alignment, Alignment.centerLeft);
    });

    testWidgets('shows snackbar and closes menu when delete fails', (tester) async {
      const myPubkey = 'my-pubkey';

      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(pubkey: myPubkey),
            pubkey: myPubkey,
            onReaction: (_) async {},
            onDelete: () async {
              throw Exception('Delete failed');
            },
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Message actions'), findsOneWidget);

      await tester.tap(find.byKey(const Key('delete_button')));
      await tester.pumpAndSettle();

      expect(find.text('Failed to delete message. Please try again.'), findsOneWidget);
      expect(find.text('Message actions'), findsNothing);
    });

    testWidgets('calls onReaction and closes menu when reaction button is tapped', (tester) async {
      String? receivedEmoji;

      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(),
            pubkey: 'user-pubkey',
            onReaction: (emoji) async {
              receivedEmoji = emoji;
            },
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Message actions'), findsOneWidget);

      await tester.tap(find.text('❤'));
      await tester.pumpAndSettle();

      expect(receivedEmoji, '❤');
      expect(find.text('Message actions'), findsNothing);
    });

    testWidgets('shows snackbar and closes menu when reaction fails', (tester) async {
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: _createTestMessage(),
            pubkey: 'user-pubkey',
            onReaction: (emoji) async {
              throw Exception('Reaction failed');
            },
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      expect(find.text('Message actions'), findsOneWidget);

      await tester.tap(find.text('❤'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to send reaction. Please try again.'), findsOneWidget);
      expect(find.text('Message actions'), findsNothing);
    });

    testWidgets('highlights emojis user has already reacted with', (tester) async {
      const myPubkey = 'my-pubkey';
      final message = _createTestMessage(
        pubkey: 'other-user',
        reactions: ReactionSummary(
          byEmoji: [
            EmojiReaction(emoji: '❤', count: BigInt.one, users: const [myPubkey]),
          ],
          userReactions: [
            UserReaction(user: myPubkey, emoji: '❤', createdAt: DateTime.now()),
          ],
        ),
      );

      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => MessageActionsScreen.show(
            context,
            message: message,
            pubkey: myPubkey,
            onReaction: (_) async {},
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      final heartButton = find.byKey(const Key('reaction_❤'));
      final heartContainer = tester.widget<Container>(
        find.descendant(of: heartButton, matching: find.byType(Container)),
      );
      expect(heartContainer.decoration, isNotNull);

      final thumbsUpButton = find.byKey(const Key('reaction_👍'));
      final thumbsUpContainer = tester.widget<Container>(
        find.descendant(of: thumbsUpButton, matching: find.byType(Container)),
      );
      expect(thumbsUpContainer.decoration, isNull);
    });

    group('emoji picker', () {
      Future<void> openEmojiPicker(
        WidgetTester tester, {
        Future<void> Function(String)? onReaction,
      }) async {
        await mountShowTest(
          tester,
          builder: (context) => ElevatedButton(
            onPressed: () => MessageActionsScreen.show(
              context,
              message: _createTestMessage(),
              pubkey: 'user-pubkey',
              onReaction: onReaction ?? (_) async {},
            ),
            child: const Text('Show Menu'),
          ),
        );
        await tester.tap(find.text('Show Menu'));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('emoji_picker_button')));
        await tester.pump();
      }

      testWidgets('emoji picker close button is hidden before opening', (tester) async {
        await mountShowTest(
          tester,
          builder: (context) => ElevatedButton(
            onPressed: () => MessageActionsScreen.show(
              context,
              message: _createTestMessage(),
              pubkey: 'user-pubkey',
              onReaction: (_) async {},
            ),
            child: const Text('Show Menu'),
          ),
        );
        await tester.tap(find.text('Show Menu'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('emoji_picker_close_button')), findsNothing);
      });

      testWidgets('shows close button when emoji picker is opened', (tester) async {
        await openEmojiPicker(tester);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('emoji_picker_close_button')), findsOneWidget);
      });

      testWidgets('hides close button after closing emoji picker', (tester) async {
        await openEmojiPicker(tester);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('emoji_picker_close_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('emoji_picker_close_button')), findsNothing);
      });

      testWidgets('menu remains visible when emoji picker is open', (tester) async {
        await openEmojiPicker(tester);
        await tester.pumpAndSettle();

        expect(find.text('Message actions'), findsOneWidget);
      });

      testWidgets('selecting emoji invokes onReaction and closes screen', (tester) async {
        String? reactionCapturedEmoji;
        await openEmojiPicker(
          tester,
          onReaction: (emoji) async {
            reactionCapturedEmoji = emoji;
          },
        );
        await tester.pumpAndSettle();

        final emojiPicker = tester.widget<EmojiPicker>(find.byType(EmojiPicker));
        emojiPicker.onEmojiSelected!(Category.SMILEYS, const Emoji('😀', 'grinning face'));
        await tester.pumpAndSettle();

        expect(reactionCapturedEmoji, '😀');
        expect(find.text('Message actions'), findsNothing);
        expect(find.byKey(const Key('emoji_picker_close_button')), findsNothing);
      });
    });
  });
}
