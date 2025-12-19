import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/screens/chat_list_screen.dart';
import 'package:sloth/screens/error_screen.dart';
import 'package:sloth/screens/welcome_screen.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/welcomes.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../test_helpers.dart';

const _testPubkey = 'test_pubkey';
const _testWelcomeId = 'test_welcome_id';
const _welcomerPubkey = 'welcomer_pubkey';

Welcome _welcomeFactory({String groupName = '', String description = ''}) => Welcome(
  id: _testWelcomeId,
  mlsGroupId: 'mls',
  nostrGroupId: 'nostr',
  groupName: groupName,
  groupDescription: description,
  groupAdminPubkeys: const [],
  groupRelays: const [],
  welcomer: _welcomerPubkey,
  memberCount: 5,
  state: WelcomeState.pending,
  createdAt: BigInt.zero,
);

class _MockApi implements RustLibApi {
  Completer<Welcome>? welcomeCompleter;
  Welcome? welcome;
  String? displayName;
  bool acceptCalled = false;
  bool declineCalled = false;
  Exception? errorToThrow;

  void reset() {
    welcomeCompleter = null;
    welcome = _welcomeFactory();
    displayName = null;
    acceptCalled = false;
    declineCalled = false;
    errorToThrow = null;
  }

  @override
  Future<Welcome> crateApiWelcomesFindWelcomeByEventId({
    required String pubkey,
    required String welcomeEventId,
  }) {
    if (welcomeCompleter != null) return welcomeCompleter!.future;
    if (welcome == null) {
      return Future.error(Exception('Welcome not found'));
    }
    return Future.value(welcome);
  }

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) {
    return Future.value(FlutterMetadata(displayName: displayName, custom: const {}));
  }

  @override
  Future<void> crateApiWelcomesAcceptWelcome({
    required String pubkey,
    required String welcomeEventId,
  }) async {
    acceptCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<void> crateApiWelcomesDeclineWelcome({
    required String pubkey,
    required String welcomeEventId,
  }) async {
    declineCalled = true;
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<List<Welcome>> crateApiWelcomesPendingWelcomes({required String pubkey}) {
    return Future.value([]);
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

  Future<void> pumpInviteScreen(WidgetTester tester, {bool settle = true}) async {
    await mountTestApp(
      tester,
      overrides: [authProvider.overrideWith(() => _MockAuthNotifier())],
    );

    await tester.pumpAndSettle();
    Routes.pushToWelcome(
      tester.element(find.byType(Scaffold)),
      _testWelcomeId,
    );
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  group('WelcomeScreen', () {
    group('loading state', () {
      testWidgets('shows loading indicator while welcome is being fetched', (tester) async {
        final welcomeRequest = Completer<Welcome>();
        _api.welcomeCompleter = welcomeRequest;
        await pumpInviteScreen(tester, settle: false);
        await tester.pump(const Duration(milliseconds: 1));
        expect(find.byKey(const Key('welcome_loading_indicator')), findsOneWidget);
        expect(find.text('Accept'), findsNothing);
        expect(find.text('Decline'), findsNothing);

        welcomeRequest.complete(_welcomeFactory());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('welcome_loading_indicator')), findsNothing);
        expect(find.text('Accept'), findsOneWidget);
        expect(find.text('Decline'), findsOneWidget);
      });
    });

    group('when fetching welcome fails', () {
      testWidgets('renders error screen', (tester) async {
        _api.welcome = null;
        await pumpInviteScreen(tester);

        expect(find.byType(ErrorScreen), findsOneWidget);
      });
      testWidgets('shows not found message when welcome is missing', (tester) async {
        _api.welcome = null;
        await pumpInviteScreen(tester);

        expect(find.text('Invitation not found'), findsOneWidget);
      });
    });

    group('DM invite (no group name)', () {
      testWidgets('shows welcomer name as title', (tester) async {
        _api.displayName = 'Alice';
        _api.welcome = _welcomeFactory();
        await pumpInviteScreen(tester);

        expect(find.text('Alice'), findsOneWidget);
        expect(find.text('Invited you to a secure chat'), findsOneWidget);
      });

      testWidgets('shows Unknown User when welcomer is unknown', (tester) async {
        _api.welcome = _welcomeFactory();
        await pumpInviteScreen(tester);

        expect(find.text('Unknown User'), findsOneWidget);
      });
    });

    group('group invite', () {
      testWidgets('shows group name as title', (tester) async {
        _api.displayName = 'Bob';
        _api.welcome = _welcomeFactory(groupName: 'Team Chat');
        await pumpInviteScreen(tester);

        expect(find.text('Team Chat'), findsOneWidget);
        expect(find.text('Bob invited you'), findsOneWidget);
      });

      testWidgets('shows member count', (tester) async {
        _api.welcome = _welcomeFactory(groupName: 'Team Chat');
        await pumpInviteScreen(tester);

        expect(find.text('5 members'), findsOneWidget);
      });

      testWidgets('shows group description when present', (tester) async {
        _api.welcome = _welcomeFactory(
          groupName: 'Team Chat',
          description: 'A chat for the team',
        );
        await pumpInviteScreen(tester);

        expect(find.text('A chat for the team'), findsOneWidget);
      });
    });

    group('accept action', () {
      testWidgets('shows Accept and Decline buttons', (tester) async {
        await pumpInviteScreen(tester);

        expect(find.text('Accept'), findsOneWidget);
        expect(find.text('Decline'), findsOneWidget);
      });

      testWidgets('calls acceptWelcome when Accept is tapped', (tester) async {
        await pumpInviteScreen(tester);
        await tester.tap(find.text('Accept'));
        await tester.pump();

        expect(_api.acceptCalled, isTrue);
      });

      testWidgets('navigates to chat list on success', (tester) async {
        await pumpInviteScreen(tester);
        await tester.tap(find.text('Accept'));
        await tester.pumpAndSettle();

        expect(find.byType(ChatListScreen), findsOneWidget);
      });

      testWidgets('shows snackbar on error', (tester) async {
        _api.errorToThrow = Exception('Network error');
        await pumpInviteScreen(tester);
        await tester.tap(find.text('Accept'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Failed to accept'), findsOneWidget);
      });
    });

    group('decline action', () {
      testWidgets('calls declineWelcome when Decline is tapped', (tester) async {
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

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.textContaining('Failed to decline'), findsOneWidget);
      });
    });

    group('navigation', () {
      testWidgets('close button returns to chat list', (tester) async {
        await pumpInviteScreen(tester);
        await tester.tap(find.byKey(const Key('close_button')));
        await tester.pumpAndSettle();

        expect(find.byType(WelcomeScreen), findsNothing);
      });
    });
  });
}
