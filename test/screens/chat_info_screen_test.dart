import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/wn_avatar.dart';
import 'package:sloth/widgets/wn_button.dart';
import 'package:sloth/widgets/wn_copy_card.dart';
import 'package:sloth/widgets/wn_slate.dart';
import 'package:sloth/widgets/wn_slate_navigation_header.dart';
import '../mocks/mock_clipboard.dart' show clearClipboardMock, mockClipboard, mockClipboardFailing;
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

const _testPubkey = testPubkeyA;
const _otherPubkey = testPubkeyB;

class _MockApi extends MockWnApi {
  FlutterMetadata metadata = const FlutterMetadata(custom: {});
  Completer<FlutterMetadata>? metadataCompleter;
  Completer<void>? followCompleter;
  Completer<void>? unfollowCompleter;
  Exception? followError;
  Exception? unfollowError;
  final followCalls = <({String account, String target})>[];
  final unfollowCalls = <({String account, String target})>[];
  final Map<String, String> pubkeyToNpub = {};
  final Set<String> followingPubkeys = {};

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required String pubkey,
    required bool blockingDataSync,
  }) async {
    if (metadataCompleter != null) return metadataCompleter!.future;
    return metadata;
  }

  @override
  Future<void> crateApiAccountsFollowUser({
    required String accountPubkey,
    required String userToFollowPubkey,
  }) async {
    followCalls.add((account: accountPubkey, target: userToFollowPubkey));
    if (followCompleter != null) await followCompleter!.future;
    if (followError != null) throw followError!;
  }

  @override
  Future<void> crateApiAccountsUnfollowUser({
    required String accountPubkey,
    required String userToUnfollowPubkey,
  }) async {
    unfollowCalls.add((account: accountPubkey, target: userToUnfollowPubkey));
    if (unfollowCompleter != null) await unfollowCompleter!.future;
    if (unfollowError != null) throw unfollowError!;
  }

  @override
  Future<bool> crateApiAccountsIsFollowingUser({
    required String accountPubkey,
    required String userPubkey,
  }) async {
    return followingPubkeys.contains(userPubkey);
  }

  @override
  String crateApiUtilsNpubFromHexPubkey({required String hexPubkey}) {
    final npub = pubkeyToNpub[hexPubkey];
    if (npub == null) throw Exception('Unknown pubkey');
    return npub;
  }

  @override
  void reset() {
    super.reset();
    metadata = const FlutterMetadata(custom: {});
    metadataCompleter = null;
    followCompleter = null;
    unfollowCompleter = null;
    followError = null;
    unfollowError = null;
    followCalls.clear();
    unfollowCalls.clear();
    pubkeyToNpub.clear();
    followingPubkeys.clear();
  }
}

class _MockAuthNotifier extends AuthNotifier {
  @override
  Future<String?> build() async {
    state = const AsyncData(_testPubkey);
    return _testPubkey;
  }
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));
  setUp(() => _api.reset());

  Future<void> pumpChatInfoScreen(
    WidgetTester tester, {
    required String userPubkey,
  }) async {
    _api.pubkeyToNpub[testPubkeyA] = testNpubA;
    _api.pubkeyToNpub[testPubkeyB] = testNpubB;
    await mountTestApp(
      tester,
      overrides: [authProvider.overrideWith(() => _MockAuthNotifier())],
    );
    await tester.pumpAndSettle();
    Routes.pushToChatInfo(tester.element(find.byType(Scaffold)), userPubkey);
    await tester.pumpAndSettle();
  }

  group('ChatInfoScreen', () {
    testWidgets('displays slate container', (tester) async {
      await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
      expect(find.byType(WnSlate), findsOneWidget);
    });

    testWidgets('displays screen header with Profile title', (tester) async {
      await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
      expect(find.byType(WnSlateNavigationHeader), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('displays avatar', (tester) async {
      await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
      expect(find.byType(WnAvatar), findsOneWidget);
    });

    group('with metadata', () {
      setUp(() {
        _api.metadata = const FlutterMetadata(
          displayName: 'Alice',
          name: 'alice',
          nip05: 'alice@example.com',
          about: 'I love Nostr!',
          custom: {},
        );
      });

      testWidgets('displays display name', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
        expect(find.text('Alice'), findsOneWidget);
      });

      testWidgets('displays nip05', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
        expect(find.text('alice@example.com'), findsOneWidget);
      });

      testWidgets('displays about', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
        expect(find.text('I love Nostr!'), findsOneWidget);
      });

      testWidgets('shows pubkey copy card', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: testPubkeyA);
        final copyCard = tester.widget<WnCopyCard>(find.byType(WnCopyCard));
        expect(copyCard.textToDisplay, testNpubAFormatted);
        expect(copyCard.textToCopy, testNpubA);
      });
    });

    group('with minimal metadata', () {
      setUp(() {
        _api.metadata = const FlutterMetadata(name: 'bob', custom: {});
      });

      testWidgets('falls back to name when displayName is null', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
        expect(find.text('bob'), findsOneWidget);
      });

      testWidgets('does not show nip05 when null', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
        expect(find.text('alice@example.com'), findsNothing);
      });

      testWidgets('does not show about when null', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
        expect(find.text('I love Nostr!'), findsNothing);
      });
    });

    group('follow button', () {
      setUp(() {
        _api.metadata = const FlutterMetadata(displayName: 'Other User', custom: {});
      });

      testWidgets('shows Follow button for non-followed user', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
        expect(find.text('Follow'), findsOneWidget);
      });

      testWidgets('shows Unfollow button for followed user', (tester) async {
        _api.followingPubkeys.add(_otherPubkey);
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);
        expect(find.text('Unfollow'), findsOneWidget);
      });

      testWidgets('calls follow API when Follow is tapped', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('follow_button')));
        await tester.pumpAndSettle();

        expect(_api.followCalls.length, 1);
        expect(_api.followCalls[0].account, _testPubkey);
        expect(_api.followCalls[0].target, _otherPubkey);
      });

      testWidgets('calls unfollow API when Unfollow is tapped', (tester) async {
        _api.followingPubkeys.add(_otherPubkey);
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('follow_button')));
        await tester.pumpAndSettle();

        expect(_api.unfollowCalls.length, 1);
        expect(_api.unfollowCalls[0].account, _testPubkey);
        expect(_api.unfollowCalls[0].target, _otherPubkey);
      });

      testWidgets('shows loading state during follow action', (tester) async {
        _api.followCompleter = Completer();
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('follow_button')));
        await tester.pump();

        final button = tester.widget<WnButton>(find.byType(WnButton));
        expect(button.loading, isTrue);
      });

      testWidgets('shows loading state during unfollow action', (tester) async {
        _api.followingPubkeys.add(_otherPubkey);
        _api.unfollowCompleter = Completer();
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('follow_button')));
        await tester.pump();

        final button = tester.widget<WnButton>(find.byType(WnButton));
        expect(button.loading, isTrue);
      });

      testWidgets('shows snackbar when follow fails', (tester) async {
        _api.followError = Exception('Network error');
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('follow_button')));
        await tester.pumpAndSettle();

        expect(
          find.text('Failed to update follow status. Please try again.'),
          findsOneWidget,
        );
      });

      testWidgets('shows snackbar when unfollow fails', (tester) async {
        _api.followingPubkeys.add(_otherPubkey);
        _api.unfollowError = Exception('Network error');
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('follow_button')));
        await tester.pumpAndSettle();

        expect(
          find.text('Failed to update follow status. Please try again.'),
          findsOneWidget,
        );
      });
    });

    group('own profile', () {
      setUp(() {
        _api.metadata = const FlutterMetadata(displayName: 'My Profile', custom: {});
      });

      testWidgets('does not show follow button for own profile', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _testPubkey);

        expect(find.byKey(const Key('follow_button')), findsNothing);
        expect(find.text('Follow'), findsNothing);
        expect(find.text('Unfollow'), findsNothing);
      });

      testWidgets('displays own profile data', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _testPubkey);

        expect(find.text('My Profile'), findsOneWidget);
      });
    });

    group('loading state', () {
      testWidgets('hides loading indicator when metadata loads', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('system notice', () {
      setUp(() {
        _api.metadata = const FlutterMetadata(displayName: 'Test User', custom: {});
      });

      testWidgets('shows notice when public key is copied', (tester) async {
        mockClipboard();
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('copy_button')));
        await tester.pump();

        expect(find.text('Public key copied to clipboard'), findsOneWidget);
      });

      testWidgets('shows error notice when public key copy fails', (tester) async {
        mockClipboardFailing();
        addTearDown(clearClipboardMock);
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('copy_button')));
        await tester.pumpAndSettle();

        expect(find.text('Failed to copy public key. Please try again.'), findsOneWidget);
      });

      testWidgets('shows error notice when follow action fails', (tester) async {
        _api.follows = [];
        _api.followCompleter = Completer();
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('follow_button')));
        await tester.pump();

        _api.followCompleter!.completeError(Exception('Network error'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Failed to update follow status. Please try again.'), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('navigates back when back button is pressed', (tester) async {
        await pumpChatInfoScreen(tester, userPubkey: _otherPubkey);

        await tester.tap(find.byKey(const Key('slate_back_button')));
        await tester.pumpAndSettle();

        expect(find.text('Profile'), findsNothing);
      });
    });
  });
}
