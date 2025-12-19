import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/screens/settings_screen.dart';
import 'package:sloth/screens/welcome_screen.dart';
import 'package:sloth/screens/wip_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/welcomes.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/chat_list_welcome_tile.dart';
import 'package:sloth/widgets/wn_account_bar.dart';
import 'package:sloth/widgets/wn_slate_container.dart';

import '../test_helpers.dart';

Welcome _welcome(String id) => Welcome(
  id: id,
  mlsGroupId: 'mls_$id',
  nostrGroupId: 'nostr_$id',
  groupName: 'Group $id',
  groupDescription: '',
  groupAdminPubkeys: const [],
  groupRelays: const [],
  welcomer: 'welcomer',
  memberCount: 1,
  state: WelcomeState.pending,
  createdAt: BigInt.one,
);

class _MockApi implements RustLibApi {
  List<Welcome> welcomes = [];
  int welcomesCallCount = 0;

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) async => const FlutterMetadata(custom: {});

  @override
  Future<List<Welcome>> crateApiWelcomesPendingWelcomes({
    required String pubkey,
  }) async {
    welcomesCallCount++;
    return welcomes;
  }

  @override
  Future<Welcome> crateApiWelcomesFindWelcomeByEventId({
    required String pubkey,
    required String welcomeEventId,
  }) async => welcomes.firstWhere((w) => w.id == welcomeEventId);

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
    _api.welcomes = [];
    _api.welcomesCallCount = 0;
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

    group('without welcomes', () {
      setUp(() => _api.welcomes = []);
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
        final callsBefore = _api.welcomesCallCount;
        await tester.fling(
          find.byType(SingleChildScrollView),
          const Offset(0, 300),
          1000,
        );
        await tester.pumpAndSettle();
        expect(_api.welcomesCallCount, greaterThan(callsBefore));
      });
    });

    group('with welcomes', () {
      setUp(() => _api.welcomes = [_welcome('w1'), _welcome('w2')]);

      testWidgets('shows welcome tiles', (tester) async {
        await pumpChatListScreen(tester);
        expect(find.byType(ChatListWelcomeTile), findsNWidgets(2));
      });

      testWidgets('hides empty state', (tester) async {
        await pumpChatListScreen(tester);
        expect(find.text('No chats yet'), findsNothing);
      });

      testWidgets('tapping tile navigates to welcome screen', (tester) async {
        await pumpChatListScreen(tester);
        await tester.tap(find.byType(ChatListWelcomeTile).first);
        await tester.pumpAndSettle();
        expect(find.byType(WelcomeScreen), findsOneWidget);
      });

      testWidgets('pull to refresh triggers refetch', (tester) async {
        await pumpChatListScreen(tester);
        final callsBefore = _api.welcomesCallCount;
        await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
        await tester.pumpAndSettle();
        expect(_api.welcomesCallCount, greaterThan(callsBefore));
      });
    });
  });
}
