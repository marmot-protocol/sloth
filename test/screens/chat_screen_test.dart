import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_info_screen.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/message_actions_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/api/groups.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';

import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

const _testPubkey = 'test_pubkey';
const _testGroupId = 'test_group_id';

class _MockTag implements Tag {
  final List<String> vec;
  _MockTag(this.vec);

  @override
  void dispose() {}

  @override
  bool get isDisposed => false;
}

ChatMessage _message(
  String id,
  DateTime createdAt, {
  String pubkey = 'other',
  bool isDeleted = false,
  ReactionSummary reactions = const ReactionSummary(byEmoji: [], userReactions: []),
}) => ChatMessage(
  id: id,
  pubkey: pubkey,
  content: 'Message $id',
  createdAt: createdAt,
  tags: const [],
  isReply: false,
  isDeleted: isDeleted,
  contentTokens: const [],
  reactions: reactions,
  mediaAttachments: const [],
  kind: 9,
);

class _MockApi extends MockWnApi {
  StreamController<MessageStreamItem>? controller;
  List<ChatMessage> initialMessages = [];
  String groupName = 'Test Group';
  final List<String> sentMessages = [];
  final List<({String groupId, int kind, List<Tag>? tags})> deletionCalls = [];
  final List<({String groupId, String message, int kind, List<Tag>? tags})> reactionCalls = [];
  Exception? sendError;
  Exception? deleteError;
  Exception? reactionError;
  int _sendCallCount = 0;
  bool isDm = false;
  List<String> groupMembers = [];
  final Map<String, String> pubkeyToNpub = {};

  @override
  void reset() {
    controller?.close();
    controller = null;
    initialMessages = [];
    groupName = 'Test Group';
    sentMessages.clear();
    deletionCalls.clear();
    reactionCalls.clear();
    sendError = null;
    deleteError = null;
    reactionError = null;
    _sendCallCount = 0;
    isDm = false;
    groupMembers = [];
    pubkeyToNpub.clear();
  }

  @override
  Future<Tag> crateApiUtilsTagFromVec({required List<String> vec}) async {
    return _MockTag(vec);
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
    _sendCallCount++;

    if (kind == 5) {
      if (deleteError != null) throw deleteError!;
      deletionCalls.add((groupId: groupId, kind: kind, tags: tags));
    } else if (kind == 7) {
      if (reactionError != null) throw reactionError!;
      reactionCalls.add((groupId: groupId, message: message, kind: kind, tags: tags));
    } else {
      if (sendError != null) throw sendError!;
      sentMessages.add(message);
    }
    return MessageWithTokens(
      id: 'mock_$_sendCallCount',
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

  @override
  Future<bool> crateApiGroupsGroupIsDirectMessageType({
    required Group that,
    required String accountPubkey,
  }) {
    return Future.value(isDm);
  }

  @override
  Future<List<String>> crateApiGroupsGroupMembers({
    required String pubkey,
    required String groupId,
  }) {
    return Future.value(groupMembers);
  }

  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    final npub = pubkeyToNpub[hexPubkey];
    if (npub == null) throw Exception('Unknown pubkey: $hexPubkey');
    return npub;
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

      testWidgets('does not display deleted message text', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024, 1, 2)),
          _message('m2', DateTime(2024, 1, 3), isDeleted: true),
        ];
        await pumpChatScreen(tester);

        expect(find.text('Message m2'), findsNothing);
      });
    });

    group('navigation', () {
      testWidgets('back button navigates to chat list', (tester) async {
        await pumpChatScreen(tester);
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();
        expect(find.byType(ChatListScreen), findsOneWidget);
      });

      testWidgets('menu button navigates to wip screen for group chat', (tester) async {
        await pumpChatScreen(tester);
        await tester.tap(find.byKey(const Key('menu_button')));
        await tester.pumpAndSettle();
        expect(find.byType(WipScreen), findsOneWidget);
      });

      testWidgets('menu button navigates to chat info screen for DM', (tester) async {
        _api.isDm = true;
        _api.groupMembers = [_testPubkey, 'other_member_pubkey'];
        _api.pubkeyToNpub['other_member_pubkey'] = 'npub1othermember';
        await pumpChatScreen(tester);
        await tester.tap(find.byKey(const Key('menu_button')));
        await tester.pumpAndSettle();
        expect(find.byType(ChatInfoScreen), findsOneWidget);
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

    group('message actions', () {
      Future<void> longPressMessage(WidgetTester tester, String messageId) async {
        final messageFinder = find.text('Message $messageId');
        await tester.longPress(messageFinder);
        await tester.pumpAndSettle();
      }

      testWidgets('opens on long press', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024)),
        ];
        await pumpChatScreen(tester);

        await longPressMessage(tester, 'm1');

        expect(find.byType(MessageActionsScreen), findsOneWidget);
      });

      testWidgets('shows Delete button for own message', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024), pubkey: _testPubkey),
        ];
        await pumpChatScreen(tester);

        await longPressMessage(tester, 'm1');

        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('hides Delete button for other user message', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024), pubkey: 'other_user'),
        ];
        await pumpChatScreen(tester);

        await longPressMessage(tester, 'm1');

        expect(find.text('Delete'), findsNothing);
      });

      testWidgets('closes when close button is tapped', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024)),
        ];
        await pumpChatScreen(tester);

        await longPressMessage(tester, 'm1');

        await tester.tap(find.byKey(const Key('slate_close_button')));
        await tester.pumpAndSettle();

        expect(find.byType(MessageActionsScreen), findsNothing);
      });

      testWidgets('unfocuses text field when opening', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024)),
        ];
        await pumpChatScreen(tester);

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.focusNode!.hasFocus, isTrue);

        await longPressMessage(tester, 'm1');

        expect(textField.focusNode!.hasFocus, isFalse);
      });

      testWidgets('unfocuses text field when closing message actions', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024)),
        ];
        await pumpChatScreen(tester);

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.focusNode!.hasFocus, isTrue);

        await longPressMessage(tester, 'm1');
        expect(textField.focusNode!.hasFocus, isFalse);

        await tester.tap(find.byKey(const Key('slate_close_button')));
        await tester.pumpAndSettle();

        expect(find.byType(MessageActionsScreen), findsNothing);
        expect(textField.focusNode!.hasFocus, isFalse);
      });

      testWidgets('unfocuses text field after selecting reaction', (tester) async {
        _api.initialMessages = [
          _message('m1', DateTime(2024)),
        ];
        await pumpChatScreen(tester);

        await tester.tap(find.byType(TextField));
        await tester.pumpAndSettle();
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.focusNode!.hasFocus, isTrue);

        await longPressMessage(tester, 'm1');
        expect(textField.focusNode!.hasFocus, isFalse);

        await tester.tap(find.text('❤'));
        await tester.pumpAndSettle();

        expect(find.byType(MessageActionsScreen), findsNothing);
        expect(textField.focusNode!.hasFocus, isFalse);
      });

      group('message deletion', () {
        testWidgets('calls API when Delete is tapped', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024), pubkey: _testPubkey),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');

          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          expect(_api.deletionCalls.length, 1);
        });

        testWidgets('close messages actions after deletion', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024), pubkey: _testPubkey),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');

          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          expect(find.byType(MessageActionsScreen), findsNothing);
        });

        testWidgets('sends deletion to correct group', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024), pubkey: _testPubkey),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');

          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          expect(_api.deletionCalls.first.groupId, _testGroupId);
        });

        testWidgets('deletes expected message id', (tester) async {
          _api.initialMessages = [
            _message('msg_to_delete', DateTime(2024), pubkey: _testPubkey),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'msg_to_delete');

          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          final tags = _api.deletionCalls.first.tags!.cast<_MockTag>();
          expect(tags[0].vec, ['e', 'msg_to_delete']);
        });

        testWidgets('shows error snackbar when deletion fails', (tester) async {
          _api.deleteError = Exception('Network error');
          _api.initialMessages = [
            _message('m1', DateTime(2024), pubkey: _testPubkey),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');

          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          expect(_api.deletionCalls.length, 0);
          expect(find.text('Failed to delete message. Please try again.'), findsOneWidget);
          expect(find.byType(MessageActionsScreen), findsNothing);
        });
      });

      group('message reactions', () {
        testWidgets('calls API when reaction is tapped', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024)),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');

          await tester.tap(find.text('❤'));
          await tester.pumpAndSettle();

          expect(_api.reactionCalls.length, 1);
        });

        testWidgets('sends correct emoji as reaction', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024)),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');

          await tester.tap(find.text('🚀'));
          await tester.pumpAndSettle();

          expect(_api.reactionCalls.first.message, '🚀');
        });

        testWidgets('sends reaction to correct group', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024)),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');

          await tester.tap(find.text('❤'));
          await tester.pumpAndSettle();

          expect(_api.reactionCalls.first.groupId, _testGroupId);
        });

        testWidgets('includes message reference in reaction tags', (tester) async {
          _api.initialMessages = [
            _message('msg_to_react', DateTime(2024)),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'msg_to_react');

          await tester.tap(find.text('❤'));
          await tester.pumpAndSettle();

          final tags = _api.reactionCalls.first.tags!.cast<_MockTag>();
          expect(tags[0].vec, ['e', 'msg_to_react']);
        });

        testWidgets('closes message actions after sending reaction', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024)),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');

          await tester.tap(find.text('❤'));
          await tester.pumpAndSettle();

          expect(find.byType(MessageActionsScreen), findsNothing);
        });

        testWidgets('shows error snackbar when reaction fails', (tester) async {
          _api.reactionError = Exception('Network error');
          _api.initialMessages = [
            _message('m1', DateTime(2024)),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');

          await tester.tap(find.text('❤'));
          await tester.pumpAndSettle();

          expect(_api.reactionCalls.length, 0);
          expect(find.text('Failed to send reaction. Please try again.'), findsOneWidget);
          expect(find.byType(MessageActionsScreen), findsNothing);
        });
      });

      group('reaction deletion from message actions', () {
        ReactionSummary ownReaction(String emoji, String reactionId) => ReactionSummary(
          byEmoji: [
            EmojiReaction(emoji: emoji, count: BigInt.one, users: const [_testPubkey]),
          ],
          userReactions: [
            UserReaction(
              reactionId: reactionId,
              emoji: emoji,
              user: _testPubkey,
              createdAt: DateTime(2024),
            ),
          ],
        );

        testWidgets('calls delete API when tapping selected emoji', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024), reactions: ownReaction('❤', 'reaction_1')),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');
          await tester.tap(find.byKey(const Key('reaction_❤')));
          await tester.pumpAndSettle();

          expect(_api.deletionCalls.length, 1);
        });

        testWidgets('sends correct reaction ID in deletion tags', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024), reactions: ownReaction('❤', 'reaction_to_remove')),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');
          await tester.tap(find.byKey(const Key('reaction_❤')));
          await tester.pumpAndSettle();

          final tags = _api.deletionCalls.first.tags!.cast<_MockTag>();
          expect(tags[0].vec, ['e', 'reaction_to_remove']);
        });

        testWidgets('closes message actions after removing reaction', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024), reactions: ownReaction('❤', 'reaction_1')),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');
          await tester.tap(find.byKey(const Key('reaction_❤')));
          await tester.pumpAndSettle();

          expect(find.byType(MessageActionsScreen), findsNothing);
        });

        testWidgets('shows error snackbar when reaction removal fails', (tester) async {
          _api.deleteError = Exception('Network error');
          _api.initialMessages = [
            _message('m1', DateTime(2024), reactions: ownReaction('❤', 'reaction_1')),
          ];
          await pumpChatScreen(tester);

          await longPressMessage(tester, 'm1');
          await tester.tap(find.byKey(const Key('reaction_❤')));
          await tester.pumpAndSettle();

          expect(_api.deletionCalls.length, 0);
          expect(find.text('Failed to remove reaction. Please try again.'), findsOneWidget);
          expect(find.byType(MessageActionsScreen), findsNothing);
        });
      });
    });

    group('reaction pills', () {
      testWidgets('appears when reaction event arrives', (tester) async {
        _api.initialMessages = [_message('m1', DateTime(2024))];
        await pumpChatScreen(tester);
        expect(find.text('🎉'), findsNothing);

        final reactions = ReactionSummary(
          byEmoji: [
            EmojiReaction(emoji: '🎉', count: BigInt.one, users: const ['other']),
          ],
          userReactions: const [],
        );
        _api.emitMessage(_message('m1', DateTime(2024), reactions: reactions));
        await tester.pumpAndSettle();

        expect(find.text('🎉'), findsWidgets);
      });

      group('when user has no reaction to the message', () {
        ReactionSummary reactionFromOther(String emoji) => ReactionSummary(
          byEmoji: [
            EmojiReaction(emoji: emoji, count: BigInt.one, users: const ['other']),
          ],
          userReactions: const [],
        );

        testWidgets('calls API when reaction pill is tapped', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024), reactions: reactionFromOther('👍')),
          ];
          await pumpChatScreen(tester);

          await tester.tap(find.text('👍'));
          await tester.pumpAndSettle();

          expect(_api.reactionCalls.length, 1);
        });

        testWidgets('sends correct emoji from tapped pill', (tester) async {
          _api.initialMessages = [
            _message('m1', DateTime(2024), reactions: reactionFromOther('🔥')),
          ];
          await pumpChatScreen(tester);

          await tester.tap(find.text('🔥'));
          await tester.pumpAndSettle();

          expect(_api.reactionCalls.first.message, '🔥');
        });

        testWidgets('includes message reference in reaction tags', (tester) async {
          _api.initialMessages = [
            _message('msg_with_reaction', DateTime(2024), reactions: reactionFromOther('👍')),
          ];
          await pumpChatScreen(tester);

          await tester.tap(find.text('👍'));
          await tester.pumpAndSettle();

          final tags = _api.reactionCalls.first.tags!.cast<_MockTag>();
          expect(tags[0].vec, ['e', 'msg_with_reaction']);
        });
      });

      group('when user has a reaction to the message', () {
        testWidgets('calls delete API when tapping own reaction', (tester) async {
          final ownReaction = ReactionSummary(
            byEmoji: [
              EmojiReaction(emoji: '👍', count: BigInt.one, users: const [_testPubkey]),
            ],
            userReactions: [
              UserReaction(
                reactionId: 'reaction_to_delete',
                emoji: '👍',
                user: _testPubkey,
                createdAt: DateTime(2024),
              ),
            ],
          );
          _api.initialMessages = [_message('m1', DateTime(2024), reactions: ownReaction)];
          await pumpChatScreen(tester);

          await tester.tap(find.text('👍'));
          await tester.pumpAndSettle();

          expect(_api.deletionCalls.length, 1);
          final tags = _api.deletionCalls.first.tags!.cast<_MockTag>();
          expect(tags[0].vec, ['e', 'reaction_to_delete']);
        });
      });
    });
  });
}
