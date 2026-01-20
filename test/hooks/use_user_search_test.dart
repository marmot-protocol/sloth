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
  final Map<String, List<User>> followsByPubkey = {};
  final Map<String, User> userByPubkey = {};
  final Map<String, User> blockingUserByPubkey = {};
  final Map<String, String> npubToPubkey = {};
  final Map<String, String> pubkeyToNpub = {};
  final Set<String> errorPubkeys = {};
  Completer<List<User>>? followsCompleter;
  Completer<User>? userCompleter;
  final followsCalls = <String>[];
  final userCalls = <({String pubkey, bool blocking})>[];

  @override
  Future<List<User>> crateApiAccountsAccountFollows({required String pubkey}) {
    followsCalls.add(pubkey);
    if (followsCompleter != null) return followsCompleter!.future;
    return Future.value(followsByPubkey[pubkey] ?? []);
  }

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
    api.followsByPubkey.clear();
    api.userByPubkey.clear();
    api.blockingUserByPubkey.clear();
    api.npubToPubkey.clear();
    api.pubkeyToNpub.clear();
    api.errorPubkeys.clear();
    api.followsCompleter = null;
    api.userCompleter = null;
    api.followsCalls.clear();
    api.userCalls.clear();
  });

  Future<void> pump(WidgetTester tester, String accountPubkey, String searchQuery) async {
    getState = await mountHook(tester, () => useUserSearch(accountPubkey, searchQuery));
  }

  group('useUserSearch', () {
    group('when follows are loading', () {
      setUp(() => api.followsCompleter = Completer());

      testWidgets('isLoading is true and users is empty', (tester) async {
        await pump(tester, 'account1', '');

        expect(getState().isLoading, isTrue);
        expect(getState().users, isEmpty);
      });
    });

    group('without follows', () {
      testWidgets('returns empty list', (tester) async {
        await pump(tester, 'account1', '');
        await tester.pump();

        expect(getState().users, isEmpty);
        expect(getState().isLoading, isFalse);
        expect(getState().hasSearchQuery, isFalse);
      });
    });

    group('with follows', () {
      setUp(() {
        api.followsByPubkey['account1'] = [
          _userFactory('follow1', displayName: 'Alice'),
          _userFactory('follow2', displayName: 'Bob'),
        ];
      });

      testWidgets('returns users list', (tester) async {
        await pump(tester, 'account1', '');
        await tester.pump();

        expect(getState().users.length, 2);
        expect(getState().users[0].pubkey, 'follow1');
        expect(getState().users[1].pubkey, 'follow2');
      });
    });

    group('npub search', () {
      group('when query is empty', () {
        testWidgets('hasSearchQuery is false', (tester) async {
          await pump(tester, 'account1', '');
          await tester.pump();

          expect(getState().hasSearchQuery, isFalse);
        });
      });

      group('when query does not start with npub1', () {
        testWidgets('returns empty list with hasSearchQuery true', (tester) async {
          await pump(tester, 'account1', 'some random text');
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
          await pump(tester, 'account1', validNpub);
          await tester.pump();

          expect(getState().users.length, 1);
          expect(getState().users[0].pubkey, hexPubkey);
          expect(getState().users[0].metadata.displayName, 'Found User');
        });

        testWidgets('isLoading is true while fetching', (tester) async {
          api.userCompleter = Completer();
          await pump(tester, 'account1', validNpub);

          expect(getState().isLoading, isTrue);
        });

        testWidgets('does not retry with blocking when metadata is complete', (tester) async {
          await pump(tester, 'account1', validNpub);
          await tester.pump();

          expect(api.userCalls.length, 1);
          expect(api.userCalls[0].blocking, isFalse);
        });

        testWidgets('retries with blocking when metadata is incomplete', (tester) async {
          api.userByPubkey[hexPubkey] = _userFactory(hexPubkey);
          api.blockingUserByPubkey[hexPubkey] = _userFactory(hexPubkey, displayName: 'Synced User');

          await pump(tester, 'account1', validNpub);
          await tester.pump();

          expect(api.userCalls.length, 2);
          expect(api.userCalls[0].blocking, isFalse);
          expect(api.userCalls[1].blocking, isTrue);
          expect(getState().users[0].metadata.displayName, 'Synced User');
        });

        testWidgets('returns empty list when getUser throws', (tester) async {
          api.errorPubkeys.add(hexPubkey);

          await pump(tester, 'account1', validNpub);
          await tester.pump();

          expect(getState().users, isEmpty);
          expect(getState().isLoading, isFalse);
        });
      });
    });

    group('partial npub search', () {
      setUp(() {
        api.followsByPubkey['account1'] = [
          _userFactory('pub1', displayName: 'Alice'),
          _userFactory('pub2', displayName: 'Bob'),
          _userFactory('pub3', displayName: 'Charlie'),
        ];
        api.pubkeyToNpub['pub1'] = 'npub1alice111111111111111111111111111111111111111111111111111';
        api.pubkeyToNpub['pub2'] = 'npub1bob22222222222222222222222222222222222222222222222222222';
        api.pubkeyToNpub['pub3'] = 'npub1alice333333333333333333333333333333333333333333333333333';
      });

      testWidgets('returns all follows for partial npub1 prefix queries', (
        tester,
      ) async {
        await pump(tester, 'account1', 'n');
        await tester.pump();
        expect(getState().users.length, 3);
        await pump(tester, 'account1', 'np');
        await tester.pump();
        expect(getState().users.length, 3);
        await pump(tester, 'account1', 'npu');
        await tester.pump();
        expect(getState().users.length, 3);
        await pump(tester, 'account1', 'npub');
        await tester.pump();
        expect(getState().users.length, 3);
        await pump(tester, 'account1', 'npub1');
        await tester.pump();
        expect(getState().users.length, 3);
      });

      testWidgets('filters follows by npub prefix', (tester) async {
        await pump(tester, 'account1', 'npub1ali');
        await tester.pump();

        expect(getState().users.length, 2);
        expect(getState().users.map((u) => u.pubkey), containsAll(['pub1', 'pub3']));
      });

      testWidgets('filters follows case-insensitively', (tester) async {
        await pump(tester, 'account1', 'NPUB1ALI');
        await tester.pump();

        expect(getState().users.length, 2);
      });

      testWidgets('returns empty list when no matches', (tester) async {
        await pump(tester, 'account1', 'npub1xyz');
        await tester.pump();

        expect(getState().users, isEmpty);
        expect(getState().hasSearchQuery, isTrue);
      });

      testWidgets('returns all follows when query is empty', (tester) async {
        await pump(tester, 'account1', '');
        await tester.pump();

        expect(getState().users.length, 3);
      });

      testWidgets('excludes follows with invalid pubkeys', (tester) async {
        api.followsByPubkey['account1'] = [
          _userFactory('valid_pub', displayName: 'Alice'),
          _userFactory('invalid_pub', displayName: 'Bob'),
        ];
        api.pubkeyToNpub['valid_pub'] =
            'npub1alice111111111111111111111111111111111111111111111111111';

        await pump(tester, 'account1', 'npub1ali');
        await tester.pump();

        expect(getState().users.length, 1);
        expect(getState().users[0].pubkey, 'valid_pub');
      });
    });
  });
}
