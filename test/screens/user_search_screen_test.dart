import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/users.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';

import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

const _emptyMetadata = FlutterMetadata(custom: {});

User _userFactory(String pubkey, {String? displayName}) => User(
  pubkey: pubkey,
  metadata: FlutterMetadata(displayName: displayName, custom: const {}),
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

class _MockApi extends MockWnApi {
  final Map<String, User> userByPubkey = {};
  final Map<String, String> npubToPubkey = {};
  final Map<String, String> pubkeyToNpub = {};
  final Set<String> errorPubkeys = {};

  @override
  Future<List<User>> crateApiAccountsAccountFollows({required String pubkey}) async {
    return follows;
  }

  @override
  Future<User> crateApiUsersGetUser({
    required String pubkey,
    required bool blockingDataSync,
  }) async {
    if (errorPubkeys.contains(pubkey)) throw Exception('User not found');
    final user = userByPubkey[pubkey];
    if (user == null) throw Exception('User not found');
    return user;
  }

  @override
  String crateApiUtilsHexPubkeyFromNpub({required String npub}) {
    final pubkey = npubToPubkey[npub];
    if (pubkey == null) throw Exception('Invalid npub');
    return pubkey;
  }

  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    final npub = pubkeyToNpub[hexPubkey];
    if (npub == null) throw Exception('Unknown pubkey');
    return npub;
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

  setUp(() {
    _api.follows = [];
    _api.userByPubkey.clear();
    _api.npubToPubkey.clear();
    _api.pubkeyToNpub.clear();
    _api.errorPubkeys.clear();
  });

  Future<void> pumpUserSearchScreen(WidgetTester tester) async {
    await mountTestApp(
      tester,
      overrides: [authProvider.overrideWith(() => _MockAuthNotifier())],
    );
    await tester.pumpAndSettle();
    Routes.pushToUserSearch(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
  }

  group('UserSearchScreen', () {
    testWidgets('displays slate container', (tester) async {
      await pumpUserSearchScreen(tester);
      expect(find.byType(WnSlate), findsOneWidget);
    });

    testWidgets('displays screen header with title', (tester) async {
      await pumpUserSearchScreen(tester);
      expect(find.byType(WnSlateNavigationHeader), findsOneWidget);
      expect(find.text('Start new chat'), findsOneWidget);
    });

    testWidgets('displays search field', (tester) async {
      await pumpUserSearchScreen(tester);
      expect(find.text('npub1...'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('tapping close icon goes back', (tester) async {
      await pumpUserSearchScreen(tester);
      await tester.tap(find.byKey(const Key('slate_close_button')));
      await tester.pumpAndSettle();
      expect(find.byType(ChatListScreen), findsOneWidget);
    });

    group('without follows', () {
      setUp(() => _api.follows = []);

      testWidgets('shows no follows message', (tester) async {
        await pumpUserSearchScreen(tester);
        expect(find.text('No follows yet'), findsOneWidget);
      });
    });

    group('with follows', () {
      setUp(() {
        _api.follows = [
          _userFactory(testPubkeyA, displayName: 'Alice'),
          _userFactory(testPubkeyB, displayName: 'Bob'),
        ];
        _api.pubkeyToNpub[testPubkeyA] = testNpubA;
        _api.pubkeyToNpub[testPubkeyB] = testNpubB;
      });

      testWidgets('shows follows list', (tester) async {
        await pumpUserSearchScreen(tester);
        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsOneWidget);
      });

      testWidgets('hides no follows message', (tester) async {
        await pumpUserSearchScreen(tester);
        expect(find.text('No follows yet'), findsNothing);
      });

      testWidgets('shows formatted npub as subtitle', (tester) async {
        await pumpUserSearchScreen(tester);
        expect(find.textContaining('npub1 a1b2c 31111'), findsOneWidget);
        expect(find.textContaining('npub1 b2c3d 42222'), findsOneWidget);
      });

      testWidgets('passes color derived from pubkey to each avatar', (tester) async {
        await pumpUserSearchScreen(tester);

        final avatars = tester.widgetList<WnAvatar>(find.byType(WnAvatar)).toList();
        expect(avatars.length, 2);
        expect(avatars[0].color, AvatarColor.violet);
        expect(avatars[1].color, AvatarColor.amber);
      });
    });

    group('npub search', () {
      const validNpub = 'npub1abc123';
      const hexPubkey = testPubkeyC;

      setUp(() {
        _api.npubToPubkey[validNpub] = hexPubkey;
        _api.pubkeyToNpub[hexPubkey] = validNpub;
        _api.userByPubkey[hexPubkey] = _userFactory(hexPubkey, displayName: 'Searched User');
        _api.follows = [_userFactory(testPubkeyC, displayName: 'Follow')];
        _api.pubkeyToNpub[testPubkeyC] = testNpubC;
      });

      testWidgets('shows search result when valid npub entered', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.enterText(find.byType(TextField), validNpub);
        await tester.pumpAndSettle();

        expect(find.text('Searched User'), findsOneWidget);
        expect(find.text('Follow'), findsNothing);
      });

      testWidgets('shows filtered follows for invalid npub format', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.enterText(find.byType(TextField), testNpubC.substring(0, 10));
        await tester.pumpAndSettle();

        expect(find.text('Follow'), findsOneWidget);
      });

      testWidgets('shows follows list when search cleared', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.enterText(find.byType(TextField), validNpub);
        await tester.pumpAndSettle();
        expect(find.text('Searched User'), findsOneWidget);

        await tester.enterText(find.byType(TextField), '');
        await tester.pumpAndSettle();
        expect(find.text('Follow'), findsOneWidget);
      });
    });

    group('user without display name', () {
      setUp(() {
        _api.follows = [
          User(
            pubkey: testPubkeyC,
            metadata: _emptyMetadata,
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
        ];
        _api.pubkeyToNpub[testPubkeyC] = testNpubC;
      });

      testWidgets('shows formatted npub as title with no subtitle', (tester) async {
        await pumpUserSearchScreen(tester);

        final listTile = tester.widget<ListTile>(find.byType(ListTile));
        expect(listTile.subtitle, isNull);
        expect(find.textContaining('npub1 c3d4e'), findsOneWidget);
      });
    });

    group('user with empty displayName but valid name', () {
      setUp(() {
        _api.follows = [
          User(
            pubkey: testPubkeyC,
            metadata: const FlutterMetadata(displayName: '', name: 'ValidName', custom: {}),
            createdAt: DateTime(2024),
            updatedAt: DateTime(2024),
          ),
        ];
        _api.pubkeyToNpub[testPubkeyC] = testNpubC;
      });

      testWidgets('falls back to name when displayName is empty', (tester) async {
        await pumpUserSearchScreen(tester);

        expect(find.text('ValidName'), findsOneWidget);
        expect(find.textContaining('npub1 c3d4e'), findsOneWidget);
      });
    });

    group('partial npub search', () {
      setUp(() {
        _api.follows = [
          _userFactory(testPubkeyA, displayName: 'Alice'),
          _userFactory(testPubkeyB, displayName: 'Bob'),
        ];
        _api.pubkeyToNpub[testPubkeyA] = testNpubA;
        _api.pubkeyToNpub[testPubkeyB] = testNpubB;
      });

      testWidgets('shows filtered follows for partial npub', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.enterText(find.byType(TextField), 'npub1a1b');
        await tester.pumpAndSettle();

        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Bob'), findsNothing);
      });

      testWidgets('shows no results when no follows match', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.enterText(find.byType(TextField), 'npub1xyz');
        await tester.pumpAndSettle();

        expect(find.text('No results'), findsOneWidget);
      });
    });

    group('non-npub search', () {
      testWidgets('shows no results for non-npub query', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.enterText(find.byType(TextField), 'random text');
        await tester.pumpAndSettle();

        expect(find.text('No results'), findsOneWidget);
      });
    });

    group('user not found', () {
      const validNpub = 'npub1notfound';
      const hexPubkey = testPubkeyD;

      setUp(() {
        _api.npubToPubkey[validNpub] = hexPubkey;
        _api.errorPubkeys.add(hexPubkey);
      });

      testWidgets('shows no results when metadata lookup fails', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.enterText(find.byType(TextField), validNpub);
        await tester.pumpAndSettle();

        expect(find.text('No results'), findsOneWidget);
      });
    });

    group('user tap navigates to start chat screen', () {
      setUp(() {
        _api.follows = [_userFactory(testPubkeyA, displayName: 'Alice')];
        _api.pubkeyToNpub[testPubkeyA] = testNpubA;
      });

      testWidgets('navigates to start chat screen when tapping user', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.tap(find.text('Alice'));
        await tester.pumpAndSettle();

        expect(find.text('Start new chat'), findsOneWidget);
        expect(find.byKey(const Key('start_chat_button')), findsOneWidget);
      });

      testWidgets('shows follow button on start chat screen', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.tap(find.text('Alice'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('follow_button')), findsOneWidget);
      });
    });

    group('search result tap navigates to start chat screen', () {
      const validNpub = 'npub1searched';
      const hexPubkey = testGroupId;

      setUp(() {
        _api.npubToPubkey[validNpub] = hexPubkey;
        _api.pubkeyToNpub[hexPubkey] = validNpub;
        _api.userByPubkey[hexPubkey] = _userFactory(hexPubkey, displayName: 'Found User');
      });

      testWidgets('navigates to start chat screen when tapping search result', (tester) async {
        await pumpUserSearchScreen(tester);
        await tester.enterText(find.byType(TextField), validNpub);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Found User'));
        await tester.pumpAndSettle();

        expect(find.text('Start new chat'), findsOneWidget);
        expect(find.byKey(const Key('start_chat_button')), findsOneWidget);
      });
    });
  });
}
