import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/screens/chat_invite_screen.dart';
import 'package:sloth/screens/chat_screen.dart';
import 'package:sloth/screens/settings_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/api/groups.dart' show ChatSummary, GroupType;
import 'package:sloth/src/rust/api/messages.dart' show MessageStreamItem, ChatMessage;
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/chat_list_tile.dart';
import 'package:sloth/widgets/wn_account_bar.dart';
import 'package:sloth/widgets/wn_slate_container.dart';
import '../test_helpers.dart';

ChatSummary _chatSummaryFactory({required String id, required bool pendingConfirmation}) =>
    ChatSummary(
      mlsGroupId: 'mls_$id',
      name: 'Chat $id',
      groupType: GroupType.group,
      createdAt: DateTime(2024),
      pendingConfirmation: pendingConfirmation,
    );

class _MockApi implements RustLibApi {
  List<ChatSummary> chatList = [];
  int chatListCallCount = 0;

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async => const FlutterMetadata(custom: {});

  @override
  Future<List<ChatSummary>> crateApiGroupsGetChatList({
    required String accountPubkey,
  }) async {
    chatListCallCount++;
    return chatList;
  }

  @override
  Stream<MessageStreamItem> crateApiMessagesSubscribeToGroupMessages({
    required String groupId,
  }) async* {
    yield const MessageStreamItem.initialSnapshot(messages: []);
  }

  @override
  Future<List<ChatMessage>> crateApiMessagesFetchAggregatedMessagesForGroup({
    required String pubkey,
    required String groupId,
  }) async {
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData('test_pubkey');
    return 'test_pubkey';
  }
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));

  setUp(() {
    _api.chatList = [];
    _api.chatListCallCount = 0;
  });

  Future<void> pumpChatListScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [authProvider.overrideWith(() => _MockAuthNotifier())],
    );
    await tester.pumpAndSettle();
  }

  group('ChatListScreen', () {
    testWidgets('displays account bar', (tester) async {
      await pumpChatListScreen(tester);
      expect(find.byType(WnAccountBar), findsOneWidget);
    });

    testWidgets('displays slate container', (tester) async {
      await pumpChatListScreen(tester);
      expect(find.byType(WnSlateContainer), findsOneWidget);
    });

    testWidgets('tapping avatar navigates to settings', (tester) async {
      await pumpChatListScreen(tester);
      await tester.tap(find.byKey(const Key('avatar_button')));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('tapping chat icon navigates to WIP screen', (tester) async {
      await pumpChatListScreen(tester);
      await tester.tap(find.byKey(const Key('chat_add_button')));
      await tester.pumpAndSettle();
      expect(find.byType(WipScreen), findsOneWidget);
    });

    group('without chats', () {
      setUp(() => _api.chatList = []);
      testWidgets('shows no chats message', (tester) async {
        await pumpChatListScreen(tester);
        expect(find.text('No chats yet'), findsOneWidget);
      });

      testWidgets('shows pull to refresh hint', (tester) async {
        await pumpChatListScreen(tester);
        expect(find.text('Pull down to refresh'), findsOneWidget);
      });

      testWidgets('pull to refresh triggers refetch', (tester) async {
        await pumpChatListScreen(tester);
        final callsBefore = _api.chatListCallCount;
        await tester.fling(
          find.byType(SingleChildScrollView),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();
        expect(_api.chatListCallCount, greaterThan(callsBefore));
      });
    });

    group('with chats', () {
      setUp(
        () => _api.chatList = [
          _chatSummaryFactory(id: 'c1', pendingConfirmation: true),
          _chatSummaryFactory(id: 'c2', pendingConfirmation: false),
        ],
      );

      testWidgets('shows chat tiles', (tester) async {
        await pumpChatListScreen(tester);
        expect(find.byType(ChatListTile), findsNWidgets(2));
      });

      testWidgets('hides empty state', (tester) async {
        await pumpChatListScreen(tester);
        expect(find.text('No chats yet'), findsNothing);
      });

      testWidgets('tapping pending chat tile navigates to invite screen', (tester) async {
        await pumpChatListScreen(tester);
        await tester.tap(find.byType(ChatListTile).first);
        await tester.pumpAndSettle();
        expect(find.byType(ChatInviteScreen), findsOneWidget);
      });

      testWidgets('tapping accepted chat tile navigates to chat screen', (tester) async {
        await pumpChatListScreen(tester);
        await tester.tap(find.byType(ChatListTile).last);
        await tester.pumpAndSettle();
        expect(find.byType(ChatScreen), findsOneWidget);
      });

      testWidgets('pull to refresh triggers refetch', (tester) async {
        await pumpChatListScreen(tester);
        final callsBefore = _api.chatListCallCount;
        await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
        await tester.pumpAndSettle();
        expect(_api.chatListCallCount, greaterThan(callsBefore));
      });
    });
  });
}
