import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:whitenoise/providers/auth_provider.dart';
import 'package:whitenoise/screens/chat_invite_screen.dart';
import 'package:whitenoise/screens/chat_screen.dart';
import 'package:whitenoise/screens/settings_screen.dart';
import 'package:whitenoise/screens/user_search_screen.dart';
import 'package:whitenoise/src/rust/api/chat_list.dart';
import 'package:whitenoise/src/rust/api/groups.dart';
import 'package:whitenoise/src/rust/api/messages.dart' show ChatMessage;
import 'package:whitenoise/src/rust/frb_generated.dart';
import 'package:whitenoise/widgets/chat_list_tile.dart';
import 'package:whitenoise/widgets/wn_account_bar.dart';
import 'package:whitenoise/widgets/wn_chat_list.dart';
import 'package:whitenoise/widgets/wn_slate.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

ChatSummary _chatSummary({required String id, required bool pendingConfirmation}) => ChatSummary(
  mlsGroupId: id,
  name: 'Chat $id',
  groupType: GroupType.group,
  createdAt: DateTime(2024),
  pendingConfirmation: pendingConfirmation,
  unreadCount: BigInt.zero,
);

class _MockApi extends MockWnApi {
  StreamController<ChatListStreamItem>? controller;
  List<ChatSummary> initialChats = [];

  @override
  void reset() {
    controller?.close();
    controller = null;
    initialChats = [];
  }

  @override
  Stream<ChatListStreamItem> crateApiChatListSubscribeToChatList({
    required String accountPubkey,
  }) {
    controller?.close();
    controller = StreamController<ChatListStreamItem>.broadcast();
    Future.microtask(() {
      controller?.add(ChatListStreamItem.initialSnapshot(items: initialChats));
    });
    return controller!.stream;
  }

  @override
  Future<Group> crateApiGroupsGetGroup({
    required String accountPubkey,
    required String groupId,
  }) async => Group(
    mlsGroupId: groupId,
    nostrGroupId: '',
    name: 'Test',
    description: '',
    adminPubkeys: const [],
    epoch: BigInt.zero,
    state: GroupState.active,
  );

  @override
  Future<List<ChatMessage>> crateApiMessagesFetchAggregatedMessagesForGroup({
    required String pubkey,
    required String groupId,
  }) async {
    return [];
  }
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData(testPubkeyA);
    return testPubkeyA;
  }
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));
  setUp(() => _api.reset());

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

      expect(find.byType(WnSlate), findsOneWidget);
    });

    testWidgets('displays chat list', (tester) async {
      await pumpChatListScreen(tester);

      expect(find.byType(WnChatList), findsOneWidget);
    });

    testWidgets('tapping avatar navigates to settings', (tester) async {
      await pumpChatListScreen(tester);
      await tester.tap(find.byKey(const Key('avatar_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('tapping chat icon navigates to user search', (tester) async {
      await pumpChatListScreen(tester);
      await tester.tap(find.byKey(const Key('chat_add_button')));
      await tester.pumpAndSettle();
      expect(find.byType(UserSearchScreen), findsOneWidget);
    });

    group('without chats', () {
      testWidgets('shows no chats message', (tester) async {
        await pumpChatListScreen(tester);

        expect(find.text('No chats yet'), findsOneWidget);
      });

      testWidgets('shows start conversation hint', (tester) async {
        await pumpChatListScreen(tester);

        expect(find.text('Start a conversation'), findsOneWidget);
      });
    });

    group('with chats', () {
      setUp(
        () => _api.initialChats = [
          _chatSummary(id: testPubkeyA, pendingConfirmation: true),
          _chatSummary(id: testPubkeyB, pendingConfirmation: false),
        ],
      );

      testWidgets('shows chat tiles', (tester) async {
        await pumpChatListScreen(tester);

        expect(find.byType(ChatListTile), findsNWidgets(2));
      });

      testWidgets('shows chat tiles in the correct order', (tester) async {
        await pumpChatListScreen(tester);
        final tiles = tester.widgetList<ChatListTile>(find.byType(ChatListTile)).toList();

        expect(tiles.first.key, const Key(testPubkeyA));
        expect(tiles.last.key, const Key(testPubkeyB));
      });

      testWidgets('hides empty state', (tester) async {
        await pumpChatListScreen(tester);

        expect(find.text('No chats yet'), findsNothing);
      });

      testWidgets('tapping pending chat navigates to invite screen', (tester) async {
        await pumpChatListScreen(tester);
        await tester.tap(find.byType(ChatListTile).first);
        await tester.pumpAndSettle();

        expect(find.byType(ChatInviteScreen), findsOneWidget);
      });

      testWidgets('tapping accepted chat navigates to chat screen', (tester) async {
        await pumpChatListScreen(tester);
        await tester.tap(find.byType(ChatListTile).last);
        await tester.pumpAndSettle();

        expect(find.byType(ChatScreen), findsOneWidget);
      });
    });
  });
}
