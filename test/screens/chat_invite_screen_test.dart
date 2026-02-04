import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/chat_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/api/account_groups.dart';
import 'package:sloth/src/rust/api/groups.dart';
import 'package:sloth/src/rust/api/messages.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_message_bubble.dart';

import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

const _testPubkey = testPubkeyA;
const _testGroupId = testGroupId;

ChatMessage _message(String id, {bool isDeleted = false}) => ChatMessage(
  id: id,
  pubkey: testPubkeyB,
  content: 'Message $id',
  createdAt: DateTime(2024),
  tags: const [],
  isReply: false,
  isDeleted: isDeleted,
  contentTokens: const [],
  reactions: const ReactionSummary(byEmoji: [], userReactions: []),
  mediaAttachments: const [],
  kind: 9,
);

AccountGroup _accountGroup() => AccountGroup(
  accountPubkey: _testPubkey,
  mlsGroupId: _testGroupId,
  createdAt: PlatformInt64Util.from(0),
  updatedAt: PlatformInt64Util.from(0),
);

class _MockApi extends MockWnApi {
  List<ChatMessage> messages = [];
  String groupName = 'Test Group';
  bool acceptCalled = false;
  bool declineCalled = false;
  Exception? errorToThrow;

  @override
  void reset() {
    messages = [];
    groupName = 'Test Group';
    acceptCalled = false;
    declineCalled = false;
    errorToThrow = null;
  }

  @override
  Future<List<ChatMessage>> crateApiMessagesFetchAggregatedMessagesForGroup({
    required String pubkey,
    required String groupId,
  }) async {
    return messages;
  }

  @override
  Future<Group> crateApiGroupsGetGroup({
    required String accountPubkey,
    required String groupId,
  }) async {
    return Group(
      mlsGroupId: groupId,
      nostrGroupId: '',
      name: groupName,
      description: '',
      adminPubkeys: const [],
      epoch: BigInt.zero,
      state: GroupState.active,
    );
  }

  @override
  Future<AccountGroup> crateApiAccountGroupsAcceptAccountGroup({
    required String accountPubkey,
    required String mlsGroupId,
  }) async {
    acceptCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
    return _accountGroup();
  }

  @override
  Future<AccountGroup> crateApiAccountGroupsDeclineAccountGroup({
    required String accountPubkey,
    required String mlsGroupId,
  }) async {
    declineCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
    return _accountGroup();
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

  Future<void> pumpInviteScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [authProvider.overrideWith(() => _MockAuthNotifier())],
    );
    await tester.pumpAndSettle();
    Routes.pushToInvite(tester.element(find.byType(Scaffold)), _testGroupId);
    await tester.pumpAndSettle();
  }

  group('ChatInviteScreen', () {
    testWidgets('displays group name', (tester) async {
      _api.groupName = 'My Group';
      await pumpInviteScreen(tester);

      expect(find.text('My Group'), findsWidgets);
    });

    testWidgets('displays back button', (tester) async {
      await pumpInviteScreen(tester);

      expect(find.byKey(const Key('back_button')), findsOneWidget);
    });

    testWidgets('displays menu button', (tester) async {
      await pumpInviteScreen(tester);

      expect(find.byKey(const Key('menu_button')), findsOneWidget);
    });

    testWidgets('displays Accept button', (tester) async {
      await pumpInviteScreen(tester);

      expect(find.text('Accept'), findsOneWidget);
    });

    testWidgets('displays Decline button', (tester) async {
      await pumpInviteScreen(tester);

      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('displays avatars with color derived from mlsGroupId', (tester) async {
      await pumpInviteScreen(tester);

      final avatars = tester.widgetList<WnAvatar>(find.byType(WnAvatar)).toList();
      expect(avatars.length, 2);
      for (final avatar in avatars) {
        expect(avatar.color, AvatarColor.fromPubkey(_testGroupId));
      }
    });

    group('with no messages', () {
      testWidgets('shows empty state text', (tester) async {
        await pumpInviteScreen(tester);

        expect(find.text('You are invited to a secure chat'), findsOneWidget);
      });
    });

    group('with messages', () {
      setUp(() => _api.messages = [_message('m1'), _message('m2')]);

      testWidgets('displays messages', (tester) async {
        await pumpInviteScreen(tester);

        expect(find.byType(WnMessageBubble), findsNWidgets(2));
      });

      testWidgets('hides empty state text', (tester) async {
        await pumpInviteScreen(tester);

        expect(find.text('You are invited to a secure chat'), findsNothing);
      });

      testWidgets('does not display deleted message text', (tester) async {
        _api.messages = [_message('m1'), _message('m2', isDeleted: true)];
        await pumpInviteScreen(tester);

        expect(find.text('Message m2'), findsNothing);
      });
    });

    group('accept action', () {
      testWidgets('calls acceptAccountGroup', (tester) async {
        await pumpInviteScreen(tester);
        await tester.tap(find.text('Accept'));
        await tester.pump();

        expect(_api.acceptCalled, isTrue);
      });

      testWidgets('navigates to chat on success', (tester) async {
        await pumpInviteScreen(tester);
        await tester.tap(find.text('Accept'));
        await tester.pumpAndSettle();

        expect(find.byType(ChatScreen), findsOneWidget);
      });

      testWidgets('shows snackbar on error', (tester) async {
        _api.errorToThrow = Exception('Network error');
        await pumpInviteScreen(tester);
        await tester.tap(find.text('Accept'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Failed to accept'), findsOneWidget);
      });
    });

    group('decline action', () {
      testWidgets('calls declineAccountGroup', (tester) async {
        await pumpInviteScreen(tester);
        await tester.tap(find.text('Decline'));
        await tester.pump();

        expect(_api.declineCalled, isTrue);
      });

      testWidgets('navigates to chat list on success', (tester) async {
        await pumpInviteScreen(tester);
        await tester.tap(find.text('Decline'));
        await tester.pumpAndSettle();

        expect(find.byType(ChatListScreen), findsOneWidget);
      });

      testWidgets('shows snackbar on error', (tester) async {
        _api.errorToThrow = Exception('Network error');
        await pumpInviteScreen(tester);
        await tester.tap(find.text('Decline'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Failed to decline'), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('back button navigates to chat list', (tester) async {
        await pumpInviteScreen(tester);
        await tester.tap(find.byKey(const Key('back_button')));
        await tester.pumpAndSettle();

        expect(find.byType(ChatListScreen), findsOneWidget);
      });

      testWidgets('menu button navigates to WIP screen', (tester) async {
        await pumpInviteScreen(tester);
        await tester.tap(find.byKey(const Key('menu_button')));
        await tester.pumpAndSettle();

        expect(find.byType(WipScreen), findsOneWidget);
      });
    });
  });
}
