import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_user_search.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/users.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import '../test_helpers.dart';

User _userFactory(
  String pubkey, {
  String? name,
  String? displayName,
  String? picture,
}) => User(
  pubkey: pubkey,
  metadata: FlutterMetadata(
    name: name,
    displayName: displayName,
    picture: picture,
    custom: const {},
  ),
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

class _MockApi implements RustLibApi {
  final Map<String, User> userByPubkey = {};
  final Map<String, User> blockingUserByPubkey = {};
  final Map<String, String> npubToPubkey = {};
  final Map<String, String> pubkeyToNpub = {};
  final Set<String> errorPubkeys = {};
  Completer<User>? userCompleter;
  final userCalls = <({String pubkey, bool blocking})>[];

  @override
  Future<User> crateApiUsersGetUser({
    required String pubkey,
    required bool blockingDataSync,
  }) {
    userCalls.add((pubkey: pubkey, blocking: blockingDataSync));
    if (userCompleter != null) return userCompleter!.future;
    if (errorPubkeys.contains(pubkey)) throw Exception('User not found');
    final user = blockingDataSync
        ? (blockingUserByPubkey[pubkey] ?? userByPubkey[pubkey])
        : userByPubkey[pubkey];
    if (user == null) throw Exception('User not found');
    return Future.value(user);
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

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  final api = _MockApi();
  late UserSearchState Function() getState;

  setUpAll(() => RustLib.initMock(api: api));

  setUp(() {
    api.userByPubkey.clear();
    api.blockingUserByPubkey.clear();
    api.npubToPubkey.clear();
    api.pubkeyToNpub.clear();
    api.errorPubkeys.clear();
    api.userCompleter = null;
    api.userCalls.clear();
  });

  Future<void> pump(
    WidgetTester tester, {
    List<User> follows = const [],
    bool isLoadingFollows = false,
    String searchQuery = '',
  }) async {
    getState = await mountHook(
      tester,
      () => useUserSearch(
        follows: follows,
        isLoadingFollows: isLoadingFollows,
        searchQuery: searchQuery,
      ),
    );
  }

  group('useUserSearch', () {
    group('when follows are loading', () {
      testWidgets('isLoading is true and users is empty', (tester) async {
        await pump(tester, isLoadingFollows: true);

        expect(getState().isLoading, isTrue);
        expect(getState().users, isEmpty);
      });
    });

    group('without follows', () {
      testWidgets('returns empty list', (tester) async {
        await pump(tester);
        await tester.pump();

        expect(getState().users, isEmpty);
        expect(getState().isLoading, isFalse);
        expect(getState().hasSearchQuery, isFalse);
      });
    });

    group('with follows', () {
      final follows = [
        _userFactory('follow1', displayName: 'Alice'),
        _userFactory('follow2', displayName: 'Bob'),
      ];

      testWidgets('returns users list', (tester) async {
        await pump(tester, follows: follows);
        await tester.pump();

        expect(getState().users.length, 2);
        expect(getState().users[0].pubkey, 'follow1');
        expect(getState().users[1].pubkey, 'follow2');
      });
    });

    group('npub search', () {
      group('when query is empty', () {
        testWidgets('hasSearchQuery is false', (tester) async {
          await pump(tester);
          await tester.pump();

          expect(getState().hasSearchQuery, isFalse);
        });
      });

      group('when query does not start with npub1', () {
        testWidgets('returns empty list with hasSearchQuery true', (tester) async {
          await pump(tester, searchQuery: 'some random text');
          await tester.pump();

          expect(getState().users, isEmpty);
          expect(getState().hasSearchQuery, isTrue);
        });
      });

      group('when query is valid npub', () {
        const validNpub = 'npub1abc123';
        const hexPubkey = 'hex123';

        setUp(() {
          api.npubToPubkey[validNpub] = hexPubkey;
          api.userByPubkey[hexPubkey] = _userFactory(hexPubkey, displayName: 'Found User');
        });

        testWidgets('returns searched user in users list', (tester) async {
          await pump(tester, searchQuery: validNpub);
          await tester.pump();

          expect(getState().users.length, 1);
          expect(getState().users[0].pubkey, hexPubkey);
          expect(getState().users[0].metadata.displayName, 'Found User');
        });

        testWidgets('isLoading is true while fetching', (tester) async {
          api.userCompleter = Completer();
          await pump(tester, searchQuery: validNpub);

          expect(getState().isLoading, isTrue);
        });

        testWidgets('does not retry with blocking when metadata is complete', (tester) async {
          await pump(tester, searchQuery: validNpub);
          await tester.pump();

          expect(api.userCalls.length, 1);
          expect(api.userCalls[0].blocking, isFalse);
        });

        testWidgets('retries with blocking when metadata is incomplete', (tester) async {
          api.userByPubkey[hexPubkey] = _userFactory(hexPubkey);
          api.blockingUserByPubkey[hexPubkey] = _userFactory(hexPubkey, displayName: 'Synced User');

          await pump(tester, searchQuery: validNpub);
          await tester.pump();

          expect(api.userCalls.length, 2);
          expect(api.userCalls[0].blocking, isFalse);
          expect(api.userCalls[1].blocking, isTrue);
          expect(getState().users[0].metadata.displayName, 'Synced User');
        });

        testWidgets('returns empty list when getUser throws', (tester) async {
          api.errorPubkeys.add(hexPubkey);

          await pump(tester, searchQuery: validNpub);
          await tester.pump();

          expect(getState().users, isEmpty);
          expect(getState().isLoading, isFalse);
        });
      });
    });

    group('partial npub search', () {
      late List<User> follows;

      setUp(() {
        follows = [
          _userFactory('pub1', displayName: 'Alice'),
          _userFactory('pub2', displayName: 'Bob'),
          _userFactory('pub3', displayName: 'Charlie'),
        ];
        api.pubkeyToNpub['pub1'] = 'npub1alice111111111111111111111111111111111111111111111111111';
        api.pubkeyToNpub['pub2'] = 'npub1bob22222222222222222222222222222222222222222222222222222';
        api.pubkeyToNpub['pub3'] = 'npub1alice333333333333333333333333333333333333333333333333333';
      });

      testWidgets('returns all follows for partial npub1 prefix queries', (tester) async {
        await pump(tester, follows: follows, searchQuery: 'n');
        await tester.pump();
        expect(getState().users.length, 3);
        await pump(tester, follows: follows, searchQuery: 'np');
        await tester.pump();
        expect(getState().users.length, 3);
        await pump(tester, follows: follows, searchQuery: 'npu');
        await tester.pump();
        expect(getState().users.length, 3);
        await pump(tester, follows: follows, searchQuery: 'npub');
        await tester.pump();
        expect(getState().users.length, 3);
        await pump(tester, follows: follows, searchQuery: 'npub1');
        await tester.pump();
        expect(getState().users.length, 3);
      });

      testWidgets('filters follows by npub prefix', (tester) async {
        await pump(tester, follows: follows, searchQuery: 'npub1ali');
        await tester.pump();

        expect(getState().users.length, 2);
        expect(getState().users.map((u) => u.pubkey), containsAll(['pub1', 'pub3']));
      });

      testWidgets('filters follows case-insensitively', (tester) async {
        await pump(tester, follows: follows, searchQuery: 'NPUB1ALI');
        await tester.pump();

        expect(getState().users.length, 2);
      });

      testWidgets('returns empty list when no matches', (tester) async {
        await pump(tester, follows: follows, searchQuery: 'npub1xyz');
        await tester.pump();

        expect(getState().users, isEmpty);
        expect(getState().hasSearchQuery, isTrue);
      });

      testWidgets('returns all follows when query is empty', (tester) async {
        await pump(tester, follows: follows);
        await tester.pump();

        expect(getState().users.length, 3);
      });

      testWidgets('excludes follows with invalid pubkeys', (tester) async {
        final mixedFollows = [
          _userFactory('valid_pub', displayName: 'Alice'),
          _userFactory('invalid_pub', displayName: 'Bob'),
        ];
        api.pubkeyToNpub['valid_pub'] =
            'npub1alice111111111111111111111111111111111111111111111111111';

        await pump(tester, follows: mixedFollows, searchQuery: 'npub1ali');
        await tester.pump();

        expect(getState().users.length, 1);
        expect(getState().users[0].pubkey, 'valid_pub');
      });
    });
  });
}
