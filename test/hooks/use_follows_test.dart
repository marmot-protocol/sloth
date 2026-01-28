import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_follows.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/users.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

User _userFactory(String pubkey, {String? displayName}) => User(
  pubkey: pubkey,
  metadata: FlutterMetadata(
    displayName: displayName,
    custom: const {},
  ),
  createdAt: DateTime(2024),
  updatedAt: DateTime(2024),
);

class _MockApi extends MockWnApi {
  final Map<String, List<User>> followsByPubkey = {};
  Completer<List<User>>? followsCompleter;
  Completer<void>? followCompleter;
  Completer<void>? unfollowCompleter;
  Exception? followError;
  Exception? unfollowError;
  final followsCalls = <String>[];
  final followCalls = <({String account, String target})>[];
  final unfollowCalls = <({String account, String target})>[];

  @override
  Future<List<User>> crateApiAccountsAccountFollows({required String pubkey}) {
    followsCalls.add(pubkey);
    if (followsCompleter != null) return followsCompleter!.future;
    return Future.value(followsByPubkey[pubkey] ?? []);
  }

  @override
  Future<void> crateApiAccountsFollowUser({
    required String accountPubkey,
    required String userToFollowPubkey,
  }) {
    followCalls.add((account: accountPubkey, target: userToFollowPubkey));
    if (followError != null) return Future.error(followError!);
    if (followCompleter != null) return followCompleter!.future;
    return Future.value();
  }

  @override
  Future<void> crateApiAccountsUnfollowUser({
    required String accountPubkey,
    required String userToUnfollowPubkey,
  }) {
    unfollowCalls.add((account: accountPubkey, target: userToUnfollowPubkey));
    if (unfollowError != null) return Future.error(unfollowError!);
    if (unfollowCompleter != null) return unfollowCompleter!.future;
    return Future.value();
  }

  @override
  void reset() {
    super.reset();
    followsByPubkey.clear();
    followsCompleter = null;
    followCompleter = null;
    unfollowCompleter = null;
    followError = null;
    unfollowError = null;
    followsCalls.clear();
    followCalls.clear();
    unfollowCalls.clear();
  }
}

final _api = _MockApi();

void main() {
  late FollowsState Function() getState;

  setUpAll(() => RustLib.initMock(api: _api));
  setUp(() => _api.reset());

  Future<void> pump(WidgetTester tester, String accountPubkey) async {
    getState = await mountHook(tester, () => useFollows(accountPubkey));
  }

  group('useFollows', () {
    group('loading state', () {
      setUp(() => _api.followsCompleter = Completer());

      testWidgets('isLoading is true while fetching follows', (tester) async {
        await pump(tester, 'account1');

        expect(getState().isLoading, isTrue);
        expect(getState().follows, isEmpty);
      });

      testWidgets('isLoading becomes false after follows are fetched', (tester) async {
        _api.followsCompleter = Completer();
        await pump(tester, 'account1');

        expect(getState().isLoading, isTrue);

        _api.followsCompleter!.complete([]);
        await tester.pump();

        expect(getState().isLoading, isFalse);
      });
    });

    group('follows list', () {
      testWidgets('returns empty list when no follows', (tester) async {
        await pump(tester, 'account1');
        await tester.pump();

        expect(getState().follows, isEmpty);
        expect(getState().isLoading, isFalse);
      });

      testWidgets('returns follows list', (tester) async {
        _api.followsByPubkey['account1'] = [
          _userFactory('user1', displayName: 'Alice'),
          _userFactory('user2', displayName: 'Bob'),
        ];

        await pump(tester, 'account1');
        await tester.pump();

        expect(getState().follows.length, 2);
        expect(getState().follows[0].pubkey, 'user1');
        expect(getState().follows[1].pubkey, 'user2');
      });
    });

    group('isFollowing', () {
      setUp(() {
        _api.followsByPubkey['account1'] = [
          _userFactory('user1'),
          _userFactory('user2'),
        ];
      });

      testWidgets('returns true for followed user', (tester) async {
        await pump(tester, 'account1');
        await tester.pump();

        expect(getState().isFollowing('user1'), isTrue);
        expect(getState().isFollowing('user2'), isTrue);
      });

      testWidgets('returns false for non-followed user', (tester) async {
        await pump(tester, 'account1');
        await tester.pump();

        expect(getState().isFollowing('user3'), isFalse);
      });
    });

    group('follow action', () {
      testWidgets('calls followUser API', (tester) async {
        await pump(tester, 'account1');
        await tester.pump();

        await getState().follow('target_user');
        await tester.pump();

        expect(_api.followCalls.length, 1);
        expect(_api.followCalls[0].account, 'account1');
        expect(_api.followCalls[0].target, 'target_user');
      });

      testWidgets('sets isActionLoading during follow', (tester) async {
        _api.followCompleter = Completer();
        await pump(tester, 'account1');
        await tester.pump();

        expect(getState().isActionLoading, isFalse);

        final followFuture = getState().follow('target_user');
        await tester.pump();

        expect(getState().isActionLoading, isTrue);

        _api.followCompleter!.complete();
        await followFuture;
        await tester.pump();

        expect(getState().isActionLoading, isFalse);
      });

      testWidgets('refreshes follows after follow', (tester) async {
        await pump(tester, 'account1');
        await tester.pump();

        expect(_api.followsCalls.length, 1);

        await getState().follow('target_user');
        await tester.pump();

        expect(_api.followsCalls.length, 2);
      });

      testWidgets('handles error and resets isActionLoading', (tester) async {
        _api.followError = Exception('Network error');
        await pump(tester, 'account1');
        await tester.pump();

        expect(getState().isActionLoading, isFalse);
        expect(getState().error, isNull);

        await expectLater(getState().follow('target_user'), throwsException);
        await tester.pump();

        expect(getState().isActionLoading, isFalse);
        expect(getState().error, equals('Failed to follow user'));
        expect(_api.followCalls.length, 1);
      });

      testWidgets('clears error on next follow attempt', (tester) async {
        _api.followError = Exception('Network error');
        await pump(tester, 'account1');
        await tester.pump();

        await expectLater(getState().follow('target_user'), throwsException);
        await tester.pump();
        expect(getState().error, isNotNull);

        _api.followError = null;
        await getState().follow('target_user');
        await tester.pump();
        expect(getState().error, isNull);
      });

      testWidgets('clearError clears the error state', (tester) async {
        _api.followError = Exception('Network error');
        await pump(tester, 'account1');
        await tester.pump();

        await expectLater(getState().follow('target_user'), throwsException);
        await tester.pump();
        expect(getState().error, isNotNull);

        getState().clearError();
        await tester.pump();
        expect(getState().error, isNull);
      });
    });

    group('unfollow action', () {
      testWidgets('calls unfollowUser API', (tester) async {
        await pump(tester, 'account1');
        await tester.pump();

        await getState().unfollow('target_user');
        await tester.pump();

        expect(_api.unfollowCalls.length, 1);
        expect(_api.unfollowCalls[0].account, 'account1');
        expect(_api.unfollowCalls[0].target, 'target_user');
      });

      testWidgets('sets isActionLoading during unfollow', (tester) async {
        _api.unfollowCompleter = Completer();
        await pump(tester, 'account1');
        await tester.pump();

        expect(getState().isActionLoading, isFalse);

        final unfollowFuture = getState().unfollow('target_user');
        await tester.pump();

        expect(getState().isActionLoading, isTrue);

        _api.unfollowCompleter!.complete();
        await unfollowFuture;
        await tester.pump();

        expect(getState().isActionLoading, isFalse);
      });

      testWidgets('refreshes follows after unfollow', (tester) async {
        await pump(tester, 'account1');
        await tester.pump();

        expect(_api.followsCalls.length, 1);

        await getState().unfollow('target_user');
        await tester.pump();

        expect(_api.followsCalls.length, 2);
      });

      testWidgets('handles error and resets isActionLoading', (tester) async {
        _api.unfollowError = Exception('Network error');
        await pump(tester, 'account1');
        await tester.pump();

        expect(getState().isActionLoading, isFalse);
        expect(getState().error, isNull);

        await expectLater(getState().unfollow('target_user'), throwsException);
        await tester.pump();

        expect(getState().isActionLoading, isFalse);
        expect(getState().error, equals('Failed to unfollow user'));
        expect(_api.unfollowCalls.length, 1);
      });
    });

    group('refresh', () {
      testWidgets('re-fetches follows', (tester) async {
        _api.followsByPubkey['account1'] = [_userFactory('user1')];
        await pump(tester, 'account1');
        await tester.pump();

        expect(getState().follows.length, 1);
        expect(_api.followsCalls.length, 1);

        _api.followsByPubkey['account1'] = [
          _userFactory('user1'),
          _userFactory('user2'),
        ];

        getState().refresh();
        await tester.pumpAndSettle();

        expect(_api.followsCalls.length, 2);
        expect(getState().follows.length, 2);
      });
    });
  });
}
