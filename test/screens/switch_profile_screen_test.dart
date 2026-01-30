import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show AsyncData;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/routes.dart';
import 'package:sloth/src/rust/api/accounts.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/theme/semantic_colors.dart';
import 'package:sloth/widgets/wn_avatar.dart';

import '../mocks/mock_secure_storage.dart';
import '../mocks/mock_wn_api.dart';
import '../test_helpers.dart';

class _MockAuthNotifier extends AuthNotifier {
  String? _pubkey;
  Completer<void>? switchProfileCompleter;
  bool shouldThrowOnSwitch = false;

  _MockAuthNotifier(this._pubkey);

  @override
  Future<String?> build() async {
    if (_pubkey != null) {
      state = AsyncData(_pubkey);
    }
    return _pubkey;
  }

  @override
  Future<void> switchProfile(String pubkey) async {
    if (switchProfileCompleter != null) {
      await switchProfileCompleter!.future;
    }
    if (shouldThrowOnSwitch) {
      throw Exception('Switch failed');
    }
    _pubkey = pubkey;
    state = AsyncData(pubkey);
  }
}

void main() {
  late MockWnApi mockApi;

  setUpAll(() {
    mockApi = MockWnApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.reset();
    mockApi.getAccountsCompleter = null;
    mockApi.accounts = [
      Account(
        pubkey: testPubkeyA,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Account(
        pubkey: testPubkeyB,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  });

  Future<_MockAuthNotifier> pumpSwitchProfileScreen(
    WidgetTester tester,
    String currentPubkey, {
    _MockAuthNotifier? authNotifier,
  }) async {
    final notifier = authNotifier ?? _MockAuthNotifier(currentPubkey);
    await mountTestApp(
      tester,
      overrides: [
        authProvider.overrideWith(() => notifier),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
    Routes.pushToSettings(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
    Routes.pushToSwitchProfile(tester.element(find.byType(Scaffold)));
    await tester.pumpAndSettle();
    return notifier;
  }

  group('SwitchProfileScreen', () {
    testWidgets('displays Profiles title', (tester) async {
      await pumpSwitchProfileScreen(tester, testPubkeyA);
      expect(find.text('Profiles'), findsOneWidget);
    });

    testWidgets('displays list of accounts', (tester) async {
      await pumpSwitchProfileScreen(tester, testPubkeyA);
      expect(find.text('Display $testPubkeyA'), findsOneWidget);
      expect(find.text('Display $testPubkeyB'), findsOneWidget);
    });

    testWidgets('displays checkmark for current account', (tester) async {
      await pumpSwitchProfileScreen(tester, testPubkeyA);
      expect(find.byKey(const Key('current_account_checkmark')), findsOneWidget);
    });

    testWidgets('displays Connect Another Profile button', (tester) async {
      await pumpSwitchProfileScreen(tester, testPubkeyA);
      expect(find.text('Connect Another Profile'), findsOneWidget);
    });

    testWidgets('tapping current account goes back', (tester) async {
      await pumpSwitchProfileScreen(tester, testPubkeyA);
      expect(find.text('Profiles'), findsOneWidget);
      await tester.tap(find.text('Display $testPubkeyA'));
      await tester.pumpAndSettle();
      expect(find.text('Profiles'), findsNothing);
    });

    testWidgets('tapping different account switches profile', (tester) async {
      await pumpSwitchProfileScreen(tester, testPubkeyA);
      expect(find.text('Profiles'), findsOneWidget);
      await tester.tap(find.text('Display $testPubkeyB'));
      await tester.pumpAndSettle();
      expect(find.text('Profiles'), findsNothing);
    });

    testWidgets('tapping Connect Another Profile navigates to AddProfileScreen', (tester) async {
      await pumpSwitchProfileScreen(tester, testPubkeyA);
      await tester.tap(find.text('Connect Another Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Add a New Profile'), findsOneWidget);
    });

    testWidgets('shows no accounts message when empty', (tester) async {
      mockApi.accounts = [];
      await pumpSwitchProfileScreen(tester, testPubkeyA);
      expect(find.text('No accounts available'), findsOneWidget);
    });

    testWidgets('shows loading indicator while switching profile', (tester) async {
      final mockAuthNotifier = _MockAuthNotifier(testPubkeyA);
      mockAuthNotifier.switchProfileCompleter = Completer<void>();

      await pumpSwitchProfileScreen(
        tester,
        testPubkeyA,
        authNotifier: mockAuthNotifier,
      );

      await tester.tap(find.text('Display $testPubkeyB'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      mockAuthNotifier.switchProfileCompleter!.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('displays error message when switch fails', (tester) async {
      final mockAuthNotifier = _MockAuthNotifier(testPubkeyA);
      mockAuthNotifier.shouldThrowOnSwitch = true;

      await pumpSwitchProfileScreen(
        tester,
        testPubkeyA,
        authNotifier: mockAuthNotifier,
      );

      await tester.tap(find.text('Display $testPubkeyB'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to switch profile. Please try again.'), findsOneWidget);
    });

    testWidgets('passes color derived from pubkey to each avatar', (tester) async {
      await pumpSwitchProfileScreen(tester, testPubkeyA);

      final avatars = tester.widgetList<WnAvatar>(find.byType(WnAvatar)).toList();
      expect(avatars.length, 2);
      expect(avatars[0].color, AccentColor.violet);
      expect(avatars[1].color, AccentColor.amber);
    });
  });
}
