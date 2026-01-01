import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/api/groups.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';

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

class _MockApi implements RustLibApi {
  StreamController<MessageStreamItem>? controller;
  List<ChatMessage> initialMessages = [];
  String groupName = 'Test Group';

  void reset() {
    controller?.close();
    controller = null;
    initialMessages = [];
    groupName = 'Test Group';
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
  Future<List<String>> crateApiGroupsGroupMembers({
    required String pubkey,
    required String groupId,
  }) {
    return Future.value([]);
  }

  @override
  Future<bool> crateApiGroupsGroupIsDirectMessageType({
    required Group that,
    required String accountPubkey,
  }) {
    return Future.value(false);
  }

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) {
    return Future.value(const FlutterMetadata(custom: {}));
  }

  @override
  Future<String?> crateApiGroupsGetGroupImagePath({
    required String accountPubkey,
    required String groupId,
  }) {
    return Future.value('https://example.com/group.jpg');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async => _testPubkey;
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));
  setUp(() => _api.reset());
  tearDown(() => _api.reset());

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
  });
}
