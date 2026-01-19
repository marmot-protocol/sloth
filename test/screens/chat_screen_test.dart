import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/api/groups.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

const _testPubkey = 'test_pubkey';
const _testGroupId = 'test_group_id';

ChatMessage _message(String id, DateTime createdAt, {String pubkey = 'other'}) => ChatMessage(
  id: id,
  pubkey: pubkey,
  content: 'Message $id',
  createdAt: createdAt,
  tags: const [],
  isReply: false,
  isDeleted: false,
  contentTokens: const [],
  reactions: const ReactionSummary(byEmoji: [], userReactions: []),
  mediaAttachments: const [],
  kind: 9,
);

class _MockApi extends MockWnApi {
  StreamController<MessageStreamItem>? controller;
  List<ChatMessage> initialMessages = [];
  String groupName = 'Test Group';
  final List<String> sentMessages = [];
  Exception? sendError;

  @override
  void reset() {
    controller?.close();
    controller = null;
    initialMessages = [];
    groupName = 'Test Group';
    sentMessages.clear();
    sendError = null;
  }

  void emitMessage(ChatMessage message) {
    controller?.add(
      MessageStreamItem.update(
        update: MessageUpdate(trigger: UpdateTrigger.newMessage, message: message),
      ),
    );
  }

  @override
  Future<MessageWithTokens> crateApiMessagesSendMessageToGroup({
    required String pubkey,
    required String groupId,
    required String message,
    required int kind,
    List<Tag>? tags,
  }) async {
    if (sendError != null) throw sendError!;
    sentMessages.add(message);
    return MessageWithTokens(
      id: 'sent_${sentMessages.length}',
      pubkey: pubkey,
      kind: kind,
      createdAt: DateTime.now(),
      content: message,
      tokens: const [],
    );
  }

  @override
  Stream<MessageStreamItem> crateApiMessagesSubscribeToGroupMessages({
    required String groupId,
  }) {
    controller?.close();
    controller = StreamController<MessageStreamItem>.broadcast();
    Future.microtask(() {
      controller?.add(
        MessageStreamItem.initialSnapshot(messages: initialMessages),
      );
    });
    return controller!.stream;
  }

  @override
  Future<Group> crateApiGroupsGetGroup({
    required String accountPubkey,
    required String groupId,
  }) {
    return Future.value(
      Group(
        mlsGroupId: groupId,
        nostrGroupId: 'nostr_$groupId',
        name: groupName,
        description: '',
        adminPubkeys: const [],
        epoch: BigInt.zero,
        state: GroupState.active,
      ),
    );
  }

  @override
  Future<String?> crateApiGroupsGetGroupImagePath({
    required String accountPubkey,
    required String groupId,
  }) {
    return Future.value('https://example.com/group.jpg');
  }
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async => _testPubkey;
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));
  setUp(() => _api.reset());

  Future<void> pumpChatScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [authProvider.overrideWith(() => _MockAuthNotifier())],
    );
    await tester.pumpAndSettle();
    Routes.goToChat(
      tester.element(find.byType(Scaffold)),
      _testGroupId,
    );
    await tester.pumpAndSettle();
  }

  group('ChatScreen', () {
    testWidgets('displays group name in header', (tester) async {
      _api.groupName = 'My Chat Group';
      await pumpChatScreen(tester);

      expect(find.text('My Chat Group'), findsOneWidget);
    });

    testWidgets('displays Unknown group when group name is empty', (tester) async {
      _api.groupName = '';
      await pumpChatScreen(tester);

      expect(find.text('Unknown group'), findsOneWidget);
    });

    testWidgets('displays disabled chat input', (tester) async {
      await pumpChatScreen(tester);

      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('displays back button', (tester) async {
      await pumpChatScreen(tester);

      expect(find.byKey(const Key('back_button')), findsOneWidget);
    });

    testWidgets('displays menu button', (tester) async {
      await pumpChatScreen(tester);

      expect(find.byKey(const Key('menu_button')), findsOneWidget);
    });

    group('with no messages', () {
      testWidgets('shows empty state', (tester) async {
        await pumpChatScreen(tester);

        expect(find.text('No messages yet'), findsOneWidget);
      });
    });

    group('with messages', () {
      testWidgets('displays messages', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024, 1, 2)),
          _message('m2', DateTime(2024, 1, 3)),
        ];
        await pumpChatScreen(tester);

        expect(find.byType(WnMessageBubble), findsNWidgets(2));
      });

      testWidgets('displays message content', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024, 1, 4)),
        ];
        await pumpChatScreen(tester);

        expect(find.text('Message m1'), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('back button navigates to chat list', (tester) async {
        await pumpChatScreen(tester);
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
        expect(find.byType(ChatListScreen), findsOneWidget);
      });

      testWidgets('menu button navigates to wip screen', (tester) async {
        await pumpChatScreen(tester);
        await tester.tap(find.byKey(const Key('menu_button')));
        await tester.pumpAndSettle();
        expect(find.byType(WipScreen), findsOneWidget);
      });
    });

    group('message sending', () {
      testWidgets('send button appears when text is entered', (tester) async {
        await pumpChatScreen(tester);
        await tester.enterText(find.byType(TextField), 'Hello');
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('send_button')), findsOneWidget);
      });

      testWidgets('input is cleared after sending', (tester) async {
        await pumpChatScreen(tester);
        await tester.enterText(find.byType(TextField), 'Hello');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('send_button')));
        await tester.pumpAndSettle();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller!.text, isEmpty);
      });

      testWidgets('send button disappears after sending', (tester) async {
        await pumpChatScreen(tester);
        await tester.enterText(find.byType(TextField), 'Hello');
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('send_button')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('send_button')), findsNothing);
      });

      group('when sending fails', () {
        Future<void> attemptSend(WidgetTester tester) async {
          _api.sendError = Exception('Network error');
          await pumpChatScreen(tester);
          await tester.enterText(find.byType(TextField), 'Hello');
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('send_button')));
          await tester.pumpAndSettle();
        }

        testWidgets('input is not cleared', (tester) async {
          await attemptSend(tester);

          final textField = tester.widget<TextField>(find.byType(TextField));
          expect(textField.controller!.text, 'Hello');
        });

        testWidgets('shows error snackbar', (tester) async {
          await attemptSend(tester);

          expect(find.text('Failed to send message. Please try again.'), findsOneWidget);
        });
      });
    });

    group('message reception', () {
      testWidgets('message bubble appears when stream emits update', (tester) async {
        await pumpChatScreen(tester);
        _api.emitMessage(_message('new_msg', DateTime.now()));
        await tester.pumpAndSettle();

        expect(find.text('Message new_msg'), findsOneWidget);
      });
    });

    group('focus management', () {
      testWidgets('tapping outside unfocuses input', (tester) async {
        await pumpChatScreen(tester);
        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();

        await tester.tap(find.text('No messages yet'));
        await tester.pumpAndSettle();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.focusNode!.hasFocus, isFalse);
      });
    });

    group('auto-scroll', () {
      setUp(() {
        _api.initialMessages = List.generate(
          20,
          (i) => _message('m$i', DateTime(2024, 1, i + 1)),
        );
      });

      ScrollPosition getScrollPosition(WidgetTester tester) {
        return Scrollable.of(tester.element(find.byType(WnMessageBubble).first)).position;
      }

      testWidgets('scrolls to bottom on initial load', (tester) async {
        await pumpChatScreen(tester);
        await tester.pumpAndSettle();

        final position = getScrollPosition(tester);
        expect(position.pixels, 0);
      });

      testWidgets('scrolls to bottom when own message arrives', (tester) async {
        await pumpChatScreen(tester);
        _api.emitMessage(_message('own', DateTime.now(), pubkey: _testPubkey));
        await tester.pumpAndSettle();

        final position = getScrollPosition(tester);
        expect(position.pixels, 0);
      });

      testWidgets('scrolls when at bottom and other message arrives', (tester) async {
        await pumpChatScreen(tester);
        await tester.pumpAndSettle();

        final position = getScrollPosition(tester);
        expect(position.pixels, 0);

        _api.emitMessage(_message('other', DateTime.now()));
        await tester.pumpAndSettle();

        expect(position.pixels, 0);
      });

      testWidgets('does not scroll when not at bottom and other message arrives', (tester) async {
        await pumpChatScreen(tester);
        await tester.pumpAndSettle();

        final position = getScrollPosition(tester);
        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();

        final positionBeforeMessage = position.pixels;

        _api.emitMessage(_message('other', DateTime.now()));
        await tester.pumpAndSettle();

        expect(position.pixels, positionBeforeMessage);
      });

      testWidgets('scrolls to bottom when input is focused', (tester) async {
        await pumpChatScreen(tester);
        await tester.pumpAndSettle();

        final position = getScrollPosition(tester);
        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(TextField));
        final animationDelay = const Duration(milliseconds: 400);
        await tester.pump(animationDelay);
        await tester.pumpAndSettle();

        expect(position.pixels, 0);
      });
    });
  });
}
