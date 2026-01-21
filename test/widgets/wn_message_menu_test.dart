import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/widgets/wn_message_menu.dart';
import '../test_helpers.dart';

ChatMessage _createTestMessage({
  String id = 'msg-1',
  String pubkey = 'user-pubkey',
  String content = 'Test message content',
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
    reactions: const ReactionSummary(byEmoji: [], userReactions: []),
    mediaAttachments: const [],
    kind: 9,
  );
}

void main() {
  group('WnMessageMenu', () {
    testWidgets('displays message content', (tester) async {
      await mountWidget(
        WnMessageMenu(
          message: _createTestMessage(content: 'Test message'),
          isOwnMessage: false,
          onClose: () {},
        ),
        tester,
      );

      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('displays header', (tester) async {
      await mountWidget(
        WnMessageMenu(
          message: _createTestMessage(),
          isOwnMessage: false,
          onClose: () {},
        ),
        tester,
      );

      expect(find.text('Message actions'), findsOneWidget);
    });

    group('Reply button', () {
      testWidgets('is visible', (tester) async {
        await mountWidget(
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
          ),
          tester,
        );

        expect(find.byKey(const Key('reply_button')), findsOneWidget);
      });

      testWidgets('calls onClose when tapped', (tester) async {
        var closeCalled = false;
        await mountWidget(
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () => closeCalled = true,
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
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: true,
            onClose: () {},
            onDelete: () {},
          ),
          tester,
        );

        expect(find.byKey(const Key('delete_button')), findsOneWidget);
      });

      testWidgets('is hidden when onDelete is null', (tester) async {
        await mountWidget(
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
          ),
          tester,
        );

        expect(find.byKey(const Key('delete_button')), findsNothing);
      });

      testWidgets('calls onDelete when tapped', (tester) async {
        var deleteCalled = false;
        await mountWidget(
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: true,
            onClose: () {},
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
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () => closeCalled = true,
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
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
          ),
          tester,
        );

        for (final emoji in WnMessageMenu.reactions) {
          expect(find.byKey(Key('reaction_$emoji')), findsOneWidget);
        }
      });

      testWidgets('displays emoji picker button', (tester) async {
        await mountWidget(
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
          ),
          tester,
        );

        expect(find.byKey(const Key('emoji_picker_button')), findsOneWidget);
      });

      testWidgets('reaction button calls onClose when tapped', (tester) async {
        var closeCalled = false;
        await mountWidget(
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () => closeCalled = true,
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('reaction_❤️')));
        await tester.pumpAndSettle();

        expect(closeCalled, isTrue);
      });

      testWidgets('emoji picker button calls onClose when tapped', (tester) async {
        var closeCalled = false;
        await mountWidget(
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () => closeCalled = true,
          ),
          tester,
        );

        await tester.tap(find.byKey(const Key('emoji_picker_button')));
        await tester.pumpAndSettle();

        expect(closeCalled, isTrue);
      });
    });

    group('own message', () {
      testWidgets('aligns message preview to the right', (tester) async {
        await mountWidget(
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: true,
            onClose: () {},
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
          WnMessageMenu(
            message: _createTestMessage(),
            isOwnMessage: false,
            onClose: () {},
          ),
          tester,
        );

        final align = tester.widget<Align>(find.byType(Align).first);
        expect(align.alignment, Alignment.centerLeft);
      });
    });
  });

  group('WnMessageMenu.show()', () {
    Future<void> mountShowTest(
      WidgetTester tester, {
      required Widget Function(BuildContext context) builder,
    }) async {
      setUpTestView(tester);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: testDesignSize,
          builder: (_, _) => MaterialApp(
            home: Scaffold(body: Builder(builder: (context) => builder(context))),
          ),
        ),
      );
    }

    testWidgets('opens a route with the message menu', (tester) async {
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => WnMessageMenu.show(
            context,
            message: _createTestMessage(),
            pubkey: 'user-pubkey',
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
          onPressed: () => WnMessageMenu.show(
            context,
            message: _createTestMessage(pubkey: myPubkey),
            pubkey: myPubkey,
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
          onPressed: () => WnMessageMenu.show(
            context,
            message: _createTestMessage(pubkey: 'other-user'),
            pubkey: 'my-pubkey',
            onDelete: () async {},
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
          onPressed: () => WnMessageMenu.show(
            context,
            message: _createTestMessage(),
            pubkey: 'user-pubkey',
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

    testWidgets('calls onDelete and closes menu when delete button is tapped', (tester) async {
      var deleteCalled = false;
      const myPubkey = 'my-pubkey';

      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => WnMessageMenu.show(
            context,
            message: _createTestMessage(pubkey: myPubkey),
            pubkey: myPubkey,
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
          onPressed: () => WnMessageMenu.show(
            context,
            message: _createTestMessage(pubkey: myPubkey),
            pubkey: myPubkey,
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      final alignFinder = find.descendant(
        of: find.byType(WnMessageMenu),
        matching: find.byType(Align),
      );
      final align = tester.widget<Align>(alignFinder.first);
      expect(align.alignment, Alignment.centerRight);
    });

    testWidgets('aligns message preview left for other user message', (tester) async {
      await mountShowTest(
        tester,
        builder: (context) => ElevatedButton(
          onPressed: () => WnMessageMenu.show(
            context,
            message: _createTestMessage(pubkey: 'other-user'),
            pubkey: 'my-pubkey',
          ),
          child: const Text('Show Menu'),
        ),
      );

      await tester.tap(find.text('Show Menu'));
      await tester.pumpAndSettle();

      final alignFinder = find.descendant(
        of: find.byType(WnMessageMenu),
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
          onPressed: () => WnMessageMenu.show(
            context,
            message: _createTestMessage(pubkey: myPubkey),
            pubkey: myPubkey,
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
  });
}
